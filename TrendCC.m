function [MMM,H,Par,m] = TrendCC(LM,colorvec,Args)
% Trend data.
%   solve m_{ij} = M_j + z_i +a*(B_p-R_p)_j

arguments
    LM
    colorvec
    Args.Err = [];
    Args.JD  = [];
    
end

Err = Args.Err;
m_mat = LM;  

p = length(m_mat(:,1)) ; % # of epoches
q = length(m_mat(1,:)) ; % # of sources

% m = zeros(p*q,1) ; % designated m vector
m = [] ;% designated m vector
err  = []; % error for flaging good measurements


for k = 1 : p
   
    m   = [ m  ; m_mat(k,:)'] ;
    err = [err ;  Err(k,:)'] ;

end

Flag = true(size(m)) ;
Flag = Flag & ~isnan(m) & err < 0.1 ;

I = sparse(eye(q)) ; 

H = [];



for j = 1 : p
    
    one_j = sparse(zeros(q,p));
    one_j(:,j) = 1 ;
 
    line_j  = [ one_j  , I , colorvec ] ;
  

    H = [ H ; line_j] ; 

end

Flag = Flag & ~isnan(H(:,q+p+1)) ;

% Par = sparse(H(Flag,:))\ (m(Flag)) ; %-mean(m(logical(~isnan(m)))));
Par = lscov(H(Flag,:), m(Flag), 1./err(Flag).^2);
Resid = m - H*Par;
%y     = 
MMM = [];
MMM = [Resid(1:q)'];

for t = 2 : p

    MMM = [MMM ; Resid((t-1)*q+1:t*q)'];

end

MMMM = MMM';


end
