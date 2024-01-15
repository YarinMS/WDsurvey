function [Result] = FlagIdentification(MS,Args)
    % Identify specific flags in MatchedSources file.
    % Input  : - A MatchedSources object.
    %          * ...,key,val,...
    %            'PropFlags' - The name of the property containing flag
    %                information within the 'MS' structure. default is 'FLAGS'.
    %            'FlagsList' - A cell array of flag names to search
    %                for. default is {'NearEdge', 'Saturated', 'NaN', 'Negative'}.
    %            'Operator' - The logical operator to use for flag identification
    %                'or' for logical OR or 'and' for logical AND. default is 'or'.
    %
    % Output : - A logical array with the same size as the 'PropFlags' 
    %            property in the 'MS' structure, where each element indicates
    %            the presence or absence of the specified flags based on the
    %            chosen logical operator.
    % Author : Yehuda Stern (September 2023)
    % Example: Mask = FlagIdentification(MS);

    arguments
       MS MatchedSources
       Args.PropFlags    = 'FLAGS';
       Args.FlagsList     = {'NearEdge','Saturated','NaN','Negative'};
       Args.Opertor      = 'or';
       Args.BM           = BitDictionary; 
    end
    
    FlagsMat = Args.BM.Class(MS.Data.(Args.PropFlags));
    if  Args.Opertor == 'or'
        Result = zeros(size(FlagsMat));
        for i = 1:numel(Args.FlagsList)
            fieldindex = find(strcmp(Args.BM.Dic.BitName, Args.FlagsList{i}));
            if ~isempty(fieldindex)
                Result = Result | bitget(FlagsMat,fieldindex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{i});
            end
        end
    elseif Args.Opertor == 'and'
        Result = ones(size(FlagsMat));
        for i = 1:numel(Args.FlagsList)
            fieldindex = find(strcmp(Args.BM.Dic.BitName, Args.FlagsList{i}));
            if ~isempty(fieldindex)
                Result = Result & bitget(FlagsMat,fieldindex);
            else
                error('Field "%s" not found in dictionary', Args.Flags{i});
            end
        end
    else
        error('Invalid sighn for operator');
    end
    
end