classdef manager
    properties
        camList
        associationId
        associationId_state
        targetStateRecord
        chosenCams
    end
    methods
        function obj = manager(camList0)
            obj.camList = camList0(:)';
            obj.targetStateRecord = cell(numel(obj.camList),1);
            obj.associationId = [];
            obj.associationId_state = [];
            tmp = [];
            for i = 1:numel(camList0)
                if ~isempty(camList0{i})
                    tmp = [tmp, i];
                end
            end
            obj.chosenCams = tmp;
        end
        obj = multiviewAssociation(obj,trackers)
        obj = updateState(obj,allTrackers)
    end
end