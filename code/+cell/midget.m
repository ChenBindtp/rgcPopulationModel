function midget = midget( cardinalMeridianAngles, cardinalMeridianNames, midgetLinkingFuncParams, totalRGC )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


%% Midget RGCs

% Obtain a spline fit to RGC density values from Curcio & Allen
for mm = 1:length(cardinalMeridianAngles)
    % Obtain the spline fit function to total RGC density
    fitRGCDensitySqDegVisual = totalRGC.density.fitDegSq.(cardinalMeridianNames{mm});
    midget.density.fitDegSq.(cardinalMeridianNames{mm}) = createMidgetDensityFunc(cardinalMeridianAngles(mm),midgetLinkingFuncParams, fitRGCDensitySqDegVisual);
end

% Midget cell body sizes Liu and colleagues 2017 report midget soma sizes
% as a function of eccentricity as measured by AO-OCT:
%   Liu, Zhuolin, et al. "Imaging and quantifying ganglion cells and other
%   transparent neurons in the living human retina." Proceedings of the
%   National Academy of Sciences (2017): 201711734.
%
% Dacey 1993 (Table 1) reports a larget size of 17.9 microns.
%
%   Dacey, Dennis M. "Morphology of a small-field bistratified ganglion
%   cell type in the macaque and human retina." Visual neuroscience 10.6
%   (1993): 1081-1098.

% Support in the source data is in degrees of visual field along the
% temporal retina
midget.diameter.supportDeg = [(1.5+3)/2, (3+4.5)/2, (6+7.5)/2, (8+9.5)/2, (12+13.5)/2];
midget.diameter.sizeMM = [0.0115, 0.0113, 0.0114, 0.0118, 0.01315];

% Obtain a spline fit
midget.diameter.fitDeg = fit(midget.diameter.supportDeg', midget.diameter.sizeMM', 'poly1');

end



function midgetDensityFitDegSq = createMidgetDensityFunc(meridianAngle,midgetLinkingFuncParams, fitRGCDensitySqDegVisual)


% Define a support vector in visual degrees
regularSupportPosDegVisual = 0:0.01:30;

% Define a variable with RGC density over regular support and zero values
% at the optic disc positions
RGCDensityOverRegularSupport = ...
    zeroOpticDiscPoints(fitRGCDensitySqDegVisual(regularSupportPosDegVisual)',regularSupportPosDegVisual, meridianAngle);

% Define the mRGC density function
mRGCDensityOverRegularSupport = transformRGCToMidgetRGCDensityDacey(regularSupportPosDegVisual,RGCDensityOverRegularSupport,...
    'linkingFuncParams',midgetLinkingFuncParams);

% Perform a spline fit to the mRGC density expressed in mm and mm sq units
midgetDensityFitDegSq = fit(regularSupportPosDegVisual', mRGCDensityOverRegularSupport', 'smoothingspline');

end


