module EntryHelper
  def format_content(entry)
    if entry.content.present?
      return simple_format entry.content
    end

    if entry.html_content.present?
      return raw entry.html_content
    end

    nil
  end
end
