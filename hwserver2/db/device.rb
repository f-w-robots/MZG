class DB::Device
  def initialize hwid, db
    @db = db
    @hwid = hwid
    @record = @db[:devices].find(hwid: hwid).first
  end

  def algorithm
    algorithm_record = @db[:algorithms].find(:'algorithm-id' => @record['algorithm-id']).first
    if algorithm_record
      algorithm = algorithm_record['algorithm']
      if algorithm.start_with?('#file:')
        algorithm = open(algorithm.gsub('#file:','').strip).read
      end
      algorithm
    else
      nil
    end
  end

  def interface
    algorithm_record = @db[:interfaces].find(:'interface-id' => @record['interface-id']).first
    if algorithm_record
      algorithm = algorithm_record['interface']
      if algorithm.start_with?('#file:')
        algorithm = open(algorithm.gsub('#file:','').strip).read
      end
      algorithm
    else
      nil
    end
  end

  def manual?
    @record['manual']
  end
end
