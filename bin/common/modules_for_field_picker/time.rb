MODE_SETTINGS = {
  info:       ['set_info_only'],         # infoのみを表示
  time:       ['set_display_timestamp'], # 表記形式をtimestampのみ
  date:       ['set_display_date'],      # 表記形式を日付形式(YYYY-MM-DD系)のみ
  parsedtime: ['set_parsed_timestamp'],  # 入力形式をtimestampのみ
  parseddate: ['set_parsed_date'],       # 入力形式を日付形式のみ
  fromutc:    ['set_from_utc'],          # 入力タイムゾーンがUTC時刻のみ
  fromlocal:  ['set_from_local'],        # 入力タイムゾーンがLocal時刻のみ
  toutc:      ['set_to_utc'],            # 出力タイムゾーンがUTC時刻のみ
  tolocal:    ['set_to_local'],          # 出力タイムゾーンがLocal時刻のみ
  uu:         ['set_from_utc',   'set_to_utc'],
  ul:         ['set_from_utc',   'set_to_local'],
  lu:         ['set_from_local', 'set_to_utc'],
  ll:         ['set_from_local', 'set_to_local'],
}

TIMEZONE_UTC = '+00:00'
TIMEZONE_JST = '+09:00'
OFFSET_OF_JST_FROM_UTC = 32400

def output(items)
  items.each do |item|
    printf("%s\n", item)
  end
end

def item(q, subtitle = nil, arg = nil)
  #{title: q, subtitle: subtitle, arg: (arg.nil? ? q : arg)}
  #sprintf("%s\t%s\t%s", q, subtitle, (arg.nil? ? q : arg))
  sprintf("%s\t%s", q, subtitle)
end

def time_with_message(time, message)
  {time: time, message: message} if time
end

def make_time_local_and_utc_and_jst(year, month, day, hour, min, sec, contents, mode)
  results = []
  results << time_with_message(Time.new(year, month, day, hour, min, sec), contents + ' is parsed as Local time') if mode.from_local?
  results << time_with_message(Time.new(year, month, day, hour, min, sec, TIMEZONE_UTC), contents + ' is parsed as UTC time') if mode.from_utc?
  results
end

def parse_date_string(contents, mode)
  begin
    if (/^(\d{4})$/ =~ contents)
      return make_time_local_and_utc_and_jst($1, 1, 1, 0, 0, 0, contents, mode)
    end
    if (/^(\d{4})[\/-]?(\d{2})$/ =~ contents)
      return make_time_local_and_utc_and_jst($1, $2, 1, 0, 0, 0, contents, mode)
    end
    if (/^(\d{4})[\/-]?(\d{2})[\/-]?(\d{2})$/ =~ contents)
      return make_time_local_and_utc_and_jst($1, $2, $3, 0, 0, 0, contents, mode)
    end
    if (/^(\d{4})[\/-]?(\d{2})[\/-]?(\d{2})[T _]?(\d{2})$/ =~ contents)
      return make_time_local_and_utc_and_jst($1, $2, $3, $4, 0, 0, contents, mode)
    end
    if (/^(\d{4})[\/-]?(\d{2})[\/-]?(\d{2})[T _]?(\d{2})[:]?(\d{2})$/ =~ contents)
      return make_time_local_and_utc_and_jst($1, $2, $3, $4, $5, 0, contents, mode)
    end
    if (/^(\d{4})[\/-]?(\d{2})[\/-]?(\d{2})[T _]?(\d{2})[:]?(\d{2})[:]?(\d{2})$/ =~ contents)
      return make_time_local_and_utc_and_jst($1, $2, $3, $4, $5, $6, contents, mode)
    end
    if (/^(\d{4})[\/-]?(\d{2})[\/-]?(\d{2})[T _]?(\d{2})[:]?(\d{2})[:]?(\d{2})([+-]\d{2}:\d{2})$/ =~ contents)
      return time_with_message(Time.new($1, $2, $3, $4, $5, $6, $7), contents)
    end
  rescue => e
    return false
  end
end

def parse_unix_timestamp(contents)
  return false unless (/^\d{1,}$/ =~ contents)

  begin
    time = nil
    message = nil
    if (/^\d{13}$/ =~ contents)
      time = Time.at(contents.to_i / 1000)
      message = contents + ' is parsed UNIX timestam[msec]'
    else
      time = Time.at(contents.to_i)
      message = contents + ' is parsed UNIX timestam[sec]'
    end
    return false if time.year >= 3000
    return time_with_message(time, message)
  rescue => e
    return false
  end
end

def make_item_local_and_utc(time, format, message, mode)
  results = []
  if 0 == time.utc_offset
    results << item(time.getlocal.strftime(format), 'Local for ' + message) if mode.to_local?
    results << item(time.strftime(format), 'UTC for ' + message) if mode.to_utc?
  else
    results << item(time.strftime(format), 'Local for ' + message) if mode.to_local?
    results << item(time.getutc.strftime(format), 'UTC for ' + message) if mode.to_utc?
  end
  results
end

# Mode class definition {{{
class ModeElement
  MODE_ALL = 0

  def initialize(seeds)
    @value = MODE_ALL
    @seeds = seeds
  end

  def set_mode(key)
    unless target?(key)
      throw new Error(sprintf('Unavaiable key: %s', key))
    end
    @value = mode_value(key)
  end

  def valid?(key)
    return false unless target?(key)
    return true if MODE_ALL == @value
    mode_value(key) == @value
  end

  protected

  def mode_value(key)
    @seeds[key]
  end

  def target?(key)
    @seeds.has_key?(key)
  end
end

class Mode
  DISPLAY_MODES = {timestamp: 1, date: 2}
  PARSED_MODES  = {timestamp: 1, date: 2}
  FROM_MODES  = {utc: 1, local: 2}
  TO_MODES    = {utc: 1, local: 2}

  def initialize()
    @info_only = false
    @display = ModeElement.new(DISPLAY_MODES)
    @parsed  = ModeElement.new(PARSED_MODES)
    @from    = ModeElement.new(FROM_MODES)
    @to      = ModeElement.new(TO_MODES)
  end

  def info_only?()
    @info_only
  end
  def set_info_only()
    @info_only = true
  end

  def display_timestamp?()
    @display.valid?(:timestamp)
  end
  def display_date?()
    @display.valid?(:date)
  end
  def set_display_timestamp()
    @display.set_mode(:timestamp)
  end
  def set_display_date()
    @display.set_mode(:date)
  end

  def parsed_timestamp?()
    @parsed.valid?(:timestamp)
  end
  def parsed_date?()
    @parsed.valid?(:date)
  end
  def set_parsed_timestamp()
    @parsed.set_mode(:timestamp)
  end
  def set_parsed_date()
    @parsed.set_mode(:date)
  end

  def from_utc?()
    @from.valid?(:utc)
  end
  def from_local?()
    @from.valid?(:local)
  end
  def set_from_utc()
    @from.set_mode(:utc)
  end
  def set_from_local()
    @from.set_mode(:local)
  end

  def to_utc?()
    @to.valid?(:utc)
  end
  def to_local?()
    @to.valid?(:local)
  end
  def set_to_utc()
    @to.set_mode(:utc)
  end
  def set_to_local()
    @to.set_mode(:local)
  end
end
# }}}

def get_times(contents, mode)
  infos = []
  times = []
  if mode.parsed_date?
    date_results = parse_date_string(contents, mode)
    times += date_results.flatten if (date_results)
  end
  if mode.parsed_timestamp?
    time = parse_unix_timestamp(contents)
    times << time if (time)
  end

  if times.empty?
    infos << item('Could not parse input', contents, 'Your input without options: ' + contents)
    times << time_with_message(Time.new, 'current time')
  end

  results = times.map do |time|
    patterns = []

    if mode.display_date?
      patterns << make_item_local_and_utc(time[:time], '%Y-%m-%d %H:%M:%S', time[:message], mode)
      patterns << make_item_local_and_utc(time[:time], '%Y/%m/%d %H:%M:%S', time[:message], mode)
      patterns << make_item_local_and_utc(time[:time], '%Y/%m/%dT%H:%M:%S%:z', time[:message], mode)
      patterns << make_item_local_and_utc(time[:time], '%Y%m%d%H%M%S', time[:message], mode)
      patterns << make_item_local_and_utc(time[:time], '%Y%m%d', time[:message], mode)
    end

    if mode.display_timestamp?
      patterns << item(time[:time].strftime('%s'), 'UNIX Timestamp[sec]: ' + time[:message])
      patterns << item(time[:time].strftime('%s%L'), 'UNIX Timestamp[msec]: ' + time[:message])
    end

    patterns
  end
  [infos, results.flatten]
end

def parse_arg(arg)
  mode = Mode.new

  contents = []
  arg.split(/\s+/).each do |key|
    method_names = MODE_SETTINGS[key.to_sym]
    unless method_names.nil?
      method_names.each do |method_name|
        mode.send(method_name)
      end
      next
    end

    contents << key
  end

  [contents.join(' '), mode]
end

input = ARGV.join(' ')

contents, mode = parse_arg(input)

infos, times = get_times(contents, mode)

option_string = MODE_SETTINGS.keys.join(', ')
infos << item('Copy all filtering options', option_string, 'Option: ' + option_string)

sources = []
sources += infos
sources += times unless mode.info_only?
output(sources)

# vim: set ft=ruby fdm=marker ts=2 sw=2 ro :
