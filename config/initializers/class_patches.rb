#monkey patch base classes to add useful functionality

class String

  def self.random_string(len)
    rand_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" << "0123456789" << "abcdefghijklmnopqrstuvwxyz"
    rand_max = rand_chars.size
    ret = ""
    len.times{ ret << rand_chars[rand(rand_max)] }
    ret
  end

  def to_permalink
    self.gsub(/[^-_\s\w]/, ' ').downcase.squeeze(' ').tr(' ','-').gsub(/-+$/,'')
  end

  def to_redcloth(options={})
    unless self.blank?
      #escape and textalise
      rc = RedCloth.new(self)
      body = rc.to_html
      #place back manual escapes
      unless options.blank? || options[:escape].blank?
        body = CGI::unescapeElement(body, options[:escape])
      end
      body
    end
  end

end

class Numeric

  def commify(dec='.', sep=',')
    num = to_s.sub(/\./, dec)
    dec = Regexp.escape dec
    num.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*#{dec})/, "\\1#{sep}").reverse
  end

end

class Darkfall

  def self.extract_icon_path(base_path, id, filename)
    unless filename.blank?
      if r = /(.+)\.(.+)/.match(filename)
        File.join(base_path, id.to_s, "original_#{r[1]}.jpg")
      else
        "/images/missing.png"
      end
    else
      "/images/missing.png"
    end
  end

end

