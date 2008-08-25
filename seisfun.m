function [data]=seisfun(data,fun)
%SEISFUN    Apply function to SAClab data records
%
%    Description: SEISFUN(DATA,FUN) applies the function defined by the 
%     function handle FUN to the dependent component(s) of SAClab data 
%     records in DATA.  FUN is not expected to modify the number of points
%     in the records.  
%
%    Notes:
%     - The number of components in the output record need not match that
%       of the input record.
%     - Does not check the number of points in the output record and thus
%       does not alter the NPTS or E header fields.
%
%    System requirements: Matlab 7
%
%    Data requirements: NONE
%
%    Header changes: DEPMEN, DEPMIN, DEPMAX
%
%    Usage: data=seisfun(data,fun)
%
%    Examples:
%
%     A multi-tool of a function:
%      data=seisfun(data,@abs)
%      data=seisfun(data,@sign)
%      data=seisfun(data,@log)
%      data=seisfun(data,@sqrt)
%      data=seisfun(data,@exp)
%      data=seisfun(data,@(x)log(x)/log(4))
%      data=seisfun(data,@(x)x.^3)
%      data=seisfun(data,@(x)3.^x)
%      data=seisfun(data,@(x)real(exp(-2*i*pi*x)))
%
%    See also: add, divide, mul, sub, slidefun

%     Version History:
%        Apr.  9, 2008 - initial version
%        May  12, 2008 - dep* fix
%        July 17, 2008 - documentation update, dataless support, .dep
%                        rather than .x, added history, single ch call
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated July 17, 2008 at 08:35 GMT

% todo:
%

% check nargin
error(nargchk(2,2,nargin))

% check data structure
error(seischk(data,'dep'))

% check input fun is a function
if(~isa(fun,'function_handle'))
    error('SAClab:seisfun:badInput','FUN must be a function handle!')
end

% apply function to records
depmen=nan(nrecs,1); depmin=depmen; depmax=depmen;
for i=1:numel(data)
    oclass=str2func(class(data(i).dep));
    data(i).dep=oclass(fun(double(data(i).dep)));
    if(isempty(data(i).dep)); continue; end
    depmen(i)=mean(data(i).dep(:)); 
    depmin(i)=min(data(i).dep(:)); 
    depmax(i)=max(data(i).dep(:));
end

% update header
data=ch(data,'depmen',depmen,'depmin',depmin,'depmax',depmax);

end
