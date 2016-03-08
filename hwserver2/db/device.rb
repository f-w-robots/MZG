class DB::Device < DB
  def initialize hwid, db
    @db = db
    @hwid = hwid
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

  def manual?
    @record['manual']
  end

  def group
    @record['group']
  end

  def group?
    !(@record['group'].empty? || @record['group'] == nil)
  end
end
