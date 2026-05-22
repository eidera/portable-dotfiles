#! /usr/bin/env ruby

## Required gems
# gem install nokogiri nokogiri-plist

require 'nokogiri-plist'

PLIST_PATH_FOR_NO_SETAPP = File.expand_path '~/Library/Application Support/com.tinyapp.TablePlus/Data'
PLIST_PATH_FOR_SETAPP    = File.expand_path '~/Library/Application Support/com.tinyapp.TablePlus-setapp/Data'

def output(items)
  items.each do |item|
    #printf("%s\t%s\t%s\n", item[:title], item[:subtitle], item[:arg])
    printf("%s\t%s\n", item[:title], item[:arg])
  end

  #puts "<items>"
  #items.each_with_index do |item, i| puts <<~EOS
  #  <item uid="#{i}" arg="#{item[:arg]}">
  #    <title>#{item[:title]}</title>
  #    <subtitle>#{item[:subtitle]}</subtitle>
  #    <icon>icon.png</icon>
  #  </item>
  #EOS
  #end
  #puts "</items>"
end

def item(q, subtitle = nil, arg = nil)
  {title: q, subtitle: subtitle, arg: (arg.nil? ? q : arg)}
end

class ConnectionItemMaker
  def initialize
    @items = []
  end
end

class ParsedConnectionInfo
  def initialize(connection_name, connection_id, group_id)
    @connection_name = connection_name
    @connection_id = connection_id
    @group_id = group_id
  end

  attr_reader :connection_name, :connection_id, :group_id
end

class GroupInfo
  def initialize(id, name, parent_group = nil)
    @id = id
    @name = name
    @parent_group = parent_group
  end

  attr_reader :id, :name
  attr_accessor :parent_group

  def recursive_group_name(delimiter = '/')
    return @name if (@parent_group.nil?)
    sprintf("%s%s%s", @parent_group.recursive_group_name, delimiter, @name)
  end
end

def get_path_info
  #isSetappAppli = File.exist?(PLIST_PATH_FOR_SETAPP)
  isSetappAppli = false # Setapp はもう使用しないので強制false
  isNoSetappAppli = File.exist?(PLIST_PATH_FOR_NO_SETAPP)

  raise 'TablePlus is not installed ' unless isSetappAppli || isNoSetappAppli

  data_path = isSetappAppli ? PLIST_PATH_FOR_SETAPP : PLIST_PATH_FOR_NO_SETAPP

  return {
    connection: sprintf("%s/Connections.plist", data_path),
    group: sprintf("%s/ConnectionGroups.plist", data_path),
  }
end

def parse_connection_file_path(filepath)
  plist = Nokogiri::PList(open(filepath))
  plist.map do |element|
    ParsedConnectionInfo.new(
      element['ConnectionName'],
      element['ID'],
      element['GroupID'],
    )
  end
end

def parse_connection_group_file_path(filepath)
  plist = Nokogiri::PList(open(filepath))
  parsed_results = {}
  plist.each do |element|
    parent_group_id = element['GroupID']
    id = element['ID']
    name = element['Name']
    parsed_results[id] = {
      parent_group_id: parent_group_id,
      group: GroupInfo.new(id, name),
    }
  end

  results = {}
  parsed_results.keys.each do |key|
    obj = parsed_results[key]
    parent = obj[:group].parent_group = parsed_results[obj[:parent_group_id]]
    obj[:group].parent_group = parent[:group] if parent
    results[key] = obj[:group]
  end
  results
end

def get_display_name(group_name, connection_name)
  return connection_name if (group_name.empty?)
  sprintf("%s/%s", group_name, connection_name)
end

def url_scheme(connection_id)
  # ex.
  #   tableplus://?id=04296017-35C3-4AF4-932C-A16B83F1BF59
  sprintf("tableplus://?id=%s", connection_id)
end

input = ARGV.join(' ')
keywords = input.split(' ')

path_info = get_path_info()
connection_file_path = path_info[:connection]
connection_group_file_path = path_info[:group]

connection_infos = parse_connection_file_path(connection_file_path)
parsed_group_info = parse_connection_group_file_path(connection_group_file_path)

items = []
connection_infos.each do |info|
  connection_name = info.connection_name
  connection_id = info.connection_id
  group_info = parsed_group_info[info.group_id]
  group_name = if group_info.nil?
                 ''
               else
                 group_info.recursive_group_name
               end

  display_name = get_display_name(group_name, connection_name)
  if keywords.all?{|keyword| display_name.include?(keyword)}
    items << item(display_name, '', url_scheme(connection_id))
  end
end

output(items)
