s.boot;

(
~compress = { |data, classes|
	var sets, collection, compactionOrders, size;

	size = classes.size;
	sets = [];
	collection = (0 .. size - 2); // last item is always classifier
	compactionOrders = (collection.size.factorial).collect {|i|
		collection.permute(i)
	};

	compactionOrders.collect { |order|
		var temporalData = data.deepCopy;
		order.collect { |colToExclude|
			var section, selection, subsets;
			var newRule;
			section = (0..size-1).removing(colToExclude);
			subsets = temporalData.slice(nil, section);
			selection = temporalData.slice(nil, colToExclude);
			subsets.do {|x, i|
				var completeSet = [ ];
				var selectedClass = Set.new;
				subsets.do { |y,  j |
					if(x==y) {
						completeSet = completeSet.add(j);
						if(selection.at(j).notNil){selectedClass.add(selection.at(j))};
						if( selectedClass.size == classes[ colToExclude ],{
							newRule = temporalData[i].copy;
							if(newRule.notNil) {newRule[colToExclude] = -1;
								temporalData = temporalData.add(newRule)
							};
							completeSet.collect{ |x| temporalData[x]= nil};
						});
					}
				};
			};
		};
		sets = sets.add(temporalData);
	};
	sets = sets.collect({ |x| x.reject(_.isNil) });
	sets
}
);

(
~initSettings = {
	~allSettings = List.new
};

~initSettings.value;

//Add the evaluation to the dictionary
~saveSetting = { |nodeProxy, classifier|
	~allSettings.add(nodeProxy.controlKeysValues.asDict.put(\classifier, classifier))
};

~moveClassifierKey = { |array|
	var i = array.indexOf(\classifier);
	array.swap(i, array.lastIndex)
};

~mapSettings = { |settings|

	var allKeys = settings.collect(_.keys).collect(_.as(Array))
		.flat.as(Set).as(Array).sort;
	var allValues = Dictionary.new;
	var mappings, indices, classes;

	~moveClassifierKey.(allKeys);

	allKeys.do { |key|
		var values = Set.new;
		settings.do { |dict|
			var val = dict.at(key);
			if(val.notNil) {
				values = values.add(val)
			}
		};
		allValues.put(key, values.as(Array))
	};
	mappings = settings.collect { |dict|
		dict.collect { |val, key|
			allValues.at(key).indexOf(val)
		};
	};
	indices = allKeys.collect { |key|
		mappings.collect { |dict|
			dict.at(key)
		}
	}.flop;
	classes = allKeys.collect { |key|
		allValues.at(key).size
	};
	// return a map with all the data entries
	(
		all_keys: allKeys,
		all_classes: classes,
		all_values: allValues,
		all_indices: indices
	)
};

~mapIndices = { |indices, mapping|
	var keys = mapping.all_keys;
	var values = mapping.all_values;
	var parameters = [];
	indices.collect { |x, i|
		var key = keys[i];
		var listOfValues = values[key];
		var value = listOfValues[x];
		parameters = parameters.add(key);
		parameters = parameters.add(value);
	};
	parameters
};
);

(
~mapIndices = { |indices, mapping|
	var keys = ~mappedSettings.all_keys;
	var values = ~mappedSettings.all_values;
	var parameters = [];
	indices.collect { |x, i|
		var key = keys[i];
		var listOfValues = values[key];
		var value = listOfValues[x];
		parameters = parameters.add(key);
		if(value != nil){parameters = parameters.add(value)}{
			value = ~mappedSettings.all_values.at(key).choose;
			parameters = parameters.add(value);
		};
	};
	parameters
};
)







