module MongoUtils
  module MongoDump
    def self.call(options)
      cmd = %{
        mongodump --db         #{Mongoid.respond_to?(:database) ? Mongoid.database.name : Mongoid.default_session['database'].database.name}
                  --host       #{Mongoid.respond_to?(:database) ? Mongoid.database.connection.primary.join(':') : Mongoid.sessions['default']['hosts'][0]}
                  --collection #{options[:collection]}
                  --query      "#{options[:query]}"
                  -o           #{options[:path]}
      }.squish
      `#{cmd}`      
    end
  end
end
