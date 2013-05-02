module MongoUtils
  module MongoRestore
    def self.call(options)
      cmd = %{
        mongorestore --host   #{Mongoid.respond_to?(:database) ? Mongoid.database.connection.primary.join(':') : Mongoid.sessions['default']['hosts'][0]}
                     --filter "#{options[:filter]}"
                     #{options[:path]}
      }.squish
      `#{cmd}`
    end
  end
end
