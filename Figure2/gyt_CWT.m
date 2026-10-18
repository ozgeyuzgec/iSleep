function spec = gyt_CWT(X,fs,freqs,h,dim)
% Compute time-frequency analysis of the signal with wavelet transform. The
% decomposition is performed by convolution of the signal by complex Morlet
% wavelets.
%
%   spec = gyt_CWT(X,fs,freqs,h,dim)
% Decompose signal "X" with sampling rate "fs" at frequencies "freqs"
% (vector of frequencies). Full-Width at Half-Maximum for each
% frequency must be specified in "h" (a vector of times, in seconds, of the
% same length than "freqs"). The decomposition is done along the "dim"
% dimension.

if nargin<5
    dimidx = find(size(X)>1);
    if dimidx(1)>1
        dim = dimidx(1);
    else
        dim = 1;
    end
end
        

if size(h,1)>1
 h = h';
end

if size(freqs,1)>1
 freqs = freqs';
end

if any(isnan(X(:)))
    
    % Get X dimensions and switch time dimension with the first dimension
    alldim = 1:ndims(X);
    alldim(1) = dim;
    alldim(dim) = 1;
    % Get all sizes of X
    sizes = size(X);

    if sum(sizes>1)>2
        othersizes = prod(sizes(setdiff(1:ndims(X),dim)));
    elseif sum(sizes>1)==2
        othersizes = sizes(setdiff(1:2,dim));
    else
        othersizes = 1;
    end

    % Switch time dimension and first dimension
    X = permute(X,alldim);
    % Reshape X in a [T x M] matrix with T the time dimension and M the product
    % of all other dimensions
    X = reshape(X,[size(X,1),othersizes]);

    % Generate an array of nan
    spec = nan([numel(freqs),size(X,1),othersizes]);
    % For each frequency
    for iF = 1:numel(freqs)
        % Compute the wavelet
        [PSI,t] = cwt_Morlet(fs,freqs(iF),h(iF));
        % For each column
        for iI = 1:othersizes
            % Convolve the signal with morlet wavelet
            spec(iF,:,iI) = conv(X(:,iI)',PSI,'same');
        end
    end

    % Reshape the spectrum to get back the number of dimensions
    spec = reshape(spec,[size(spec,1),size(spec,2),sizes(alldim(2:end))]);
    spec = permute(spec,[alldim+1,1]);
    
else
    % duplicate data for each frequency
    Xp = repmat(X,[ones(1,ndims(X)),length(freqs)]);

    % Find the maximum HWHM
    maxH = max(h*3);
    lims = [-1,1]*maxH;
    % Time vector
    t = linspace(lims(1),lims(2),fs*diff(lims)+1);

    % Reshape t
    alldim = 1:ndims(X)+1;
    alldim(1) = dim;
    alldim(dim) = 1;
    tR = permute(t',alldim);

    % Reshape H
    alldim = 1:ndims(X)+1;
    alldim(1) = ndims(X)+1;
    alldim(ndims(X)+1) = 1;
    hR = permute(h',alldim);

    % Reshape freqs
    fR = permute(freqs',alldim);

    % Repmats
    alldims = ones(1,ndims(X)+1);
    alldims(dim) = length(t);

    % Compute Morlet wavelets
    PSI = exp((-4*log(2)*repmat(tR,[ones(1,ndims(X)),length(h)]).^2)./repmat(hR,alldims).^2).*exp(2*1i*pi*repmat(fR,alldims).*repmat(tR,[ones(1,ndims(X)),length(h)])); 

    % Length of fft
    N = size(X,dim)+size(PSI,dim)-1;
    hW = floor(size(PSI,dim)/2)+1;

    % Compute fft of wavelets
    fPSI = fft(PSI,N,dim);
    % Normalise wavelet amplitude
    fPSI = bsxfun(@rdivide,fPSI,max(fPSI,[],dim));

    % Product of wavelet fft and signal fft and inverse fft back = convolution
    spec = ifft(bsxfun(@times,fft(Xp,N,dim),fPSI),N,dim);

    % Get rid of padding data
    alldims = repmat({':'},[1,ndims(X)+1]);
    alldims{dim} = hW-1:size(spec,dim)-hW;
    spec = spec(alldims{:});
end
end


function [PSI,t] = cwt_Morlet(tmpfs,tmpf0,tmph)
    %     [PSI,t] = cwt_Morlet(fs,f0,h)
    % 
    % Generate Morlet Wavelet based on the sampling frequence "fs", the central
    % frequency of the wavelet "f0" and the Full-Width at Half-Maximum "h".
    % "PSI" is the wavelet signal and "t" the time dimension.


    % Time limits
%     lims = tmph*[-3,3];
    lims = tmph*[-5,5];

    % Time vector
    t = linspace(lims(1),lims(2),tmpfs*diff(lims)+1);

    % Computed Morlet wavelet
    PSI = exp((-4*log(2)*t.^2)/tmph.^2).*exp(2*1i*pi*tmpf0*t);
    PSI = PSI/sum(abs(PSI));
end