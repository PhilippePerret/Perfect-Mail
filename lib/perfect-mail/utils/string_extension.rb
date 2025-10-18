class String

  # Split with no leading or ending spaces
  def splittrim(delimitor, count = nil)
    self.split(delimitor, count).map { |s| s.strip }
  end

  def blue
    "\033[0;96m#{self}\033[0m"
  end

  def green
    "\033[0;92m#{self}\033[0m"
  end

  def red
    "\033[0;91m#{self}\033[0m"
  end

end