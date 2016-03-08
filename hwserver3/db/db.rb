class DB
  protected
  def content record, field
    text = record[field]
    if text.start_with?('#file:')
      text = open(text.gsub('#file:','').strip).read
    end
    text
  end
end
