function [Nan,consecutive_nan_indices,FAP,mFap,Si,T] = find_similar_nan_patterns(light_curves)
  % Find sources with more than two consecutive NaNs
  num_images = size(light_curves, 1);
  num_sources = size(light_curves, 2);
  FAP = zeros(1,num_sources);
  mFap = zeros(num_images,num_sources);
  Si = cell(num_sources,1);
  T = 0;
  consecutive_nan_indices = {};
  Nan = {};
  Dist = {};
  for i = 1:num_sources
    is_nan = isnan(light_curves(:, i));
    diff_is_nan = diff(is_nan);
    if diff_is_nan(1) == -1
        diff_is_nan(1) = 0;
    end
    if is_nan(1) ==1 && is_nan(2) == 1 
        diff_is_nan(1) = 1;
    end
    if is_nan(end) ==1 && is_nan(end-1) == 1 
        diff_is_nan(end+1) = -1;
    end
    if is_nan(end) ==1 && is_nan(end-1) == 0 
        diff_is_nan(end) = 0;
    end
    start_nan_indices = find(diff_is_nan == 1) + 1;
    end_nan_indices = find(diff_is_nan == -1);
    if isempty(end_nan_indices)
      end_nan_indices = num_images;
    end
    if isempty(start_nan_indices)
        start_nan_indices = num_images;
    end
  
    if i == 665
        %d = 5
    end
    nan_lengths = end_nan_indices - start_nan_indices + 1;
    if any(nan_lengths >= 2)
      consecutive_nan_indices = [consecutive_nan_indices, i];
      Nan{end+1} = {[i ,  {start_nan_indices,end_nan_indices}]};
      FAP(i) = 1;
        % Create NaN pattern matrix
        flag = (median(light_curves,'omitnan') <  median(light_curves(:,i),'omitnan') -0.125) & (median(light_curves,'omitnan') <  median(light_curves(:,i),'omitnan') +0.125);
        nan_patterns = isnan(light_curves);
        col = 1;
        for j = 1:num_sources
             if j ~=i
                 if flag(j) == 1
                 Same = sum(abs(is_nan - nan_patterns(:,j)));
                 if Same == 0 
                    mFap(i,j) = 1;
                    Si{i,col} = j;
                    col = col +1;
                    T = T+1;
                 end
                 end
             end
        end

    end
  end


  % Compare NaN patterns
  % You can use pdist2 or corrcoef here
  % For example, using pdist2:

  % Find pairs of sources with similar NaN patterns based on a distance threshold
  % ...

end
