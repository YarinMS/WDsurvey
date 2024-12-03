classdef TableAggregator < handle
    properties
        Data % Property to hold the aggregated table
    end
    methods
        function obj = TableAggregator()
            obj.Data = table(); % Initialize as an empty table
        end
        function append(obj, newRow)
            obj.Data = [obj.Data; newRow]; % Append new rows to the table
        end
    end
end
