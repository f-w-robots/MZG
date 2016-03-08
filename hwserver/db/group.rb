class DB::Group < DB
  def initialize name, db
    @record = db[:groups].find(name: name).first

    class_name = "Group#{@record['_id'].to_s}"
    code = content(@record, 'code')
    Object.const_set(class_name, Class.new(::Group) { eval code })

    @const = Kernel.const_get(class_name)
  end

  def options
    @record['options']
  end

  def class_const
    @const
  end

  def name
    @record['name']
  end
end
