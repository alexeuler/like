class Token

  #token file - value; expires; id
  
  @@data=[]
  def self.data
    @@data
  end

  def self.load
    @@data=[]
    File.open File.expand_path("../tokens.csv", __FILE__), "r" do |f|
      while line=f.gets
        values=line.split(";")
        @@data << {value: values[0], expires: Time.at(values[1].to_i), id: values[2]}
      end
    end
    @@data
  end
  
  def self.dump
    File.open File.expand_path("../tokens.csv", __FILE__), "w" do |f|
      @@data.each do |tuple|
        line=[]
        tuple.each_pair {|key, value| line << value}
        line[1]=line[1].to_i
        f.puts line.join(";")
      end
      
    end
  end

end
