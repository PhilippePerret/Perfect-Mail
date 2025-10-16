class String

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