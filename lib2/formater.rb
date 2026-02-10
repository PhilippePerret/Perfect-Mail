class Formater
class << self

    def text(str)
      # Un peu de markdown
      str
      .gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
      .gsub(/\*(.+?)\*/, '<em>\1</em>')
      .gsub(/__(.+?)__/, '<u>\1</u>')
      .gsub(/\-\-\-(.+?)\-\-\-/, '<stroke>\1</stroke>')
      .gsub(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')
    end

end #/<< self
end