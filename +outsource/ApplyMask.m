function MS = ApplyMask(MS,Args)
    % Apply Mask to MatchedSources Data
    % Input  : - A MatchedSources object.
    %          * ...,key,val,...
    %            'Mask': A logical mask that determines which data points
    %                to applythe operation to.
    %            'Fields': A cell array of field names specifying which data
    %                fields in the 'MS' object to apply the mask to. Default
    %                includes {'MAG_APER_3','MAGERR_APER_3', 'MAG_PSF', 'MAGERR_PSF', 'FLAGS'}.
    %            'Value': The value to assign to masked data points. Default is
    %                'erash'.If set to 'erash', the masked data points are removed.
    %
    % Output : The updated MatchedSources object with the mask applied to the
    %          specified data fields.
    % Author : Yehuda Stern (September 2023)
    % Example: MaskedMS = ApplyMask(MS);
    
    arguments
       MS
       Args.Mask
       Args.Fields = {'MAG_APER_3','MAGERR_APER_3','MAG_PSF','MAGERR_PSF','FLAGS'};
       Args.Value  = 'erash';
    end
    if Args.Value == 'erash'
        for i=1:numel(Args.Fields)
           MS.Data.(Args.Fields{i}) = MS.Data.(Args.Fields{i})(:,Args.Mask);
        end
    else
        for i=1:numel(Args.Fields)
           MS.Data.(Args.Fields{i})(Args.Mask) = Args.Value;
        end
    end
end