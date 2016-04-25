class Device::Record
  attr_reader :hwid
  attr_reader :request

  def initialize hwid, db, request
    @db = db
    @hwid = hwid
    @request = request
    @record = db[:devices].find(hwid: hwid).first
  end

  def algorithm
    record = @db[:algorithms].find(:'algorithm-id' => @record['algorithm-id']).first
    content(record, 'algorithm') if record
  end

  def interface
    record = @db[:interfaces].find(:'interface-id' => @record['interface-id']).first
    content(record, 'interface') if record
  end

  def content record, field
    text = record[field]
    if text.start_with?('#file:')
      text = open(text.gsub('#file:','').strip).read
    end
    text
  end
end
