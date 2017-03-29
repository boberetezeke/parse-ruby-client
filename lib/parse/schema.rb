# encoding: utf-8
module Parse
  # Query objects
  # https://parseplatform.github.io/docs/rest/guide/#schema
  class Schema
    attr_accessor :class_name

    def initialize(cls_name, client = nil)
      @class_name = cls_name
      @client = client || Parse.client
    end
    
    def create(fields)
      @client.request("/schemas/#{@class_name}", :post, {"className" => @class_name, "fields" => fields_hash(fields)})
    end
    
    def get_all
      @client.request("/schemas/")['results'].map{ |schema| {'className' => schema['className'], 'fields' => wrap(schema['fields']) }}
    end
    
    def get
      wrap(@client.request("/schemas/#{@class_name}")['fields'])
    end
    
    def add_column(field, type)
      @client.request("/schemas/#{@class_name}", :post, {'className' => @class_name, 'fields' => fields_hash([{field => type}])})
    end
    
    def destroy_column
      @client.request("/schemas/#{@class_name}", :post, {'className' => @class_name, 'fields' => fields_delete_hash([{field => type}])})
    end
    
    def destroy
      @client.request("/schemas/#{@class_name}", :delete)
    end
    
    private
    
    def wrap(class_info)
      # puts "wrap: #{class_info}"
      Hash[class_info.map{|field_name, field_info| [field_name, field_info['type']]}]
    end
    
    def fields_hash(fields)
      Hash[fields.map{ |field, type| [field.to_s, type_hash(type) ] }]
    end
    
    def type_hash(type)
      m = /^(\w+)(\s*<(\w+)>)?/.match(type)
      if m[2]
        {'type' => m[1], 'targetClass' => m[3]}
      else
        {'type' => type}
      end
    end
    
    def fields_delete_hash(fields)
      fields.map{ |field, type| [field.to_s, {'__op' => 'Delete'}] }
    end
  end
end