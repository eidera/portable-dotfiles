#! /usr/bin/env ruby

## rubyzipを使用したzip/unzipユーティリティ
#   参考：http://d.hatena.ne.jp/alunko/20071021/1192908620
# # gem install rubyzip
# # #c:\rubyをruby.zipに圧縮
# ZipFileUtils.zip('c:/ruby', 'c:/ruby.zip')
# 
# #ruby.zipをc:\rubyに展開
# ZipFileUtils.unzip('c:/ruby.zip', 'c:/ruby')
# 
# #c:\rubyをruby.zipにファイル名のエンコードをShift_JISに指定して圧縮
# ZipFileUtils.zip('c:/ruby', 'c:/ruby.zip', {:fs_encoding => 'Shift_JIS'})
# 
# #ruby.zipをc:\rubyにファイル名のエンコードをShift_JISに指定して展開
# ZipFileUtils.unzip('c:/ruby.zip', 'c:/ruby', {:fs_encoding => 'Shift_JIS'})

require 'rubygems'
require 'kconv'
require 'zip'
require 'fileutils'

module ZipFileUtils
  
  # src  file or directory
  # dest  zip filename
  # options :fs_encoding=[UTF-8,Shift_JIS,EUC-JP]
  def self.zip(src, dest, options = {})
    src = File.expand_path(src)
    dest = File.expand_path(dest)
    File.unlink(dest) if File.exist?(dest)
    Zip::File.open(dest, Zip::File::CREATE) {|zf|
      if(File.file?(src))
        zf.add(encode_path(File.basename(src), options[:fs_encoding]), src)
        break
      else
        each_dir_for(src){ |path|
          if File.file?(path)
            zf.add(encode_path(relative(path, src), options[:fs_encoding]), path)
          elsif File.directory?(path)
            zf.mkdir(encode_path(relative(path, src), options[:fs_encoding]))
          end
        }
      end
    }
  end
  
  # src  zip filename
  # dest  destination directory
  # options :fs_encoding=[UTF-8,Shift_JIS,EUC-JP]
  def self.unzip(src, dest, options = {})
    FileUtils.makedirs(dest)
    Zip::ZipInputStream.open(src){ |is|
      loop do
        entry = is.get_next_entry()
        break if entry.nil?()
        dir = File.dirname(entry.name)
        FileUtils.makedirs(dest+ '/' + dir)
        path = encode_path(dest + '/' + entry.name, options[:fs_encoding])
        if(entry.file?())
          File.open(path,
                File::CREAT|File::WRONLY|File::BINARY) do |w|
           w.puts(is.read())
          end
        else
          FileUtils.makedirs(path)
        end
      end
    }
  end
  
  private
  def self.each_dir_for(dir_path, &block)
    dir = Dir.open(dir_path)
    each_file_for(dir_path){ |file_path|
      yield(file_path)
    }
  end
  
  def self.each_file_for(path, &block)
    if File.file?(path)
      yield(path)
      return true
    end
    dir = Dir.open(path)
    file_exist = false
    dir.each(){ |file|
      next if file == '.' || file == '..'
      file_exist = true if each_file_for(path + "/" + file, &block)
    }
    yield(path) unless file_exist
    return file_exist
  end
  
  def self.relative(path, base_dir)
    path[base_dir.length() + 1 .. path.length()] if path.index(base_dir) == 0
  end
  
  def self.encode_path(path, encode_s)
    return path if encode_s.nil?()
    case(encode_s)
    when('UTF-8')
      return path.toutf8()
    when('Shift_JIS')
      return path.tosjis()
    when('EUC-JP')
      return path.toeuc()
    else
      return path
    end
  end
end

def remove_unneed_file(target_dir)
  targets = [ '.DS_Store' ]

  targets.each do |target|
    Dir.glob("#{target_dir}/**/#{target}").each do |file|
      File.delete(file)
    end
  end
end

if(1 > ARGV.length)
  $stderr.printf("Usage : #{$0} target_dir [-e]\n")
  exit(1)
end

target_dir = ARGV[0]
password_option = (2 == ARGV.length) ? ARGV[1] : nil

zip_file = target_dir + '.zip'

remove_unneed_file(target_dir)

ZipFileUtils.zip(target_dir, zip_file, {:fs_encoding => 'Shift_JIS'})

unless password_option.nil?
  run = sprintf("zipcloak %s", zip_file)
  $stderr.printf("%s\n", run)
  system(run)
end
