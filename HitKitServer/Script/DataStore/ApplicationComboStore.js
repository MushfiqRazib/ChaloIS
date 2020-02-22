(function() {
	Ext.namespace('hit.excel.Data.Stores');
	hit.excel.Data.Stores.ApplicationComboStore = function(config) {

		var config = config || {};
		Ext.applyIf(config, {
					baseParams : {},

					reader : new Ext.data.JsonReader({

	                    }, ['name','baseurl'])

				});

		config.proxy = new Ext.data.HttpProxy({
					timeout : 10000000,
					headers : {
						'Content-Type' : 'application/json; charset=utf-8'
					},
					url: config.url || 'HITWebService.asmx/GetAllApplication',
					nocache : true,
					method : 'GET'
				})
		config.reader.read = function(response) {
    
			var json = response.responseText;
			var o = Ext.decode(json);
			if (!o) {
				throw {
					message : "JsonReader.read: Json object not found"
				};
			}
			return this.readRecords(o.d);
		}

		hit.excel.Data.Stores.ApplicationComboStore.superclass.constructor.call(
				this, config);
	};

	Ext.extend(hit.excel.Data.Stores.ApplicationComboStore, Ext.data.Store);
}());