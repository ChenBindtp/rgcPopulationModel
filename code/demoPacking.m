% density = 1;
% while density > 0.15
% % Generate 100 random 3d points in the unit cube
% V = rand(25,3);



density = 0;
while density < 0.35
% Generate 100 random 3d points in the unit cube
V = rand(50,3);
% Construct their Delaunay triangulation: tetrahedral mesh
T = delaunay(V(:,1),V(:,2),V(:,3));
% Gather all edges of the tet mesh
E = [ T(:,1) T(:,2); T(:,2) T(:,3); T(:,3) T(:,4); T(:,4) T(:,1)];
% include both edge directions
E = [E; fliplr(E)];
% Indices of source vertex of each edge as seen by each other vertex
EE1 = repmat(E(:,1),1,size(V,1));
% length of each edge
d= (sqrt(sum((V(E(:,1),:) - V(E(:,2),:)).^2,2)));
% lengths as seen by each other vertex
DD = repmat(d,[1,size(V,1)]);
% indices of all vertices as see by each edge (source vertex)
II = repmat(1:size(V,1),size(E,1),1);
% create a mask that is infinity if source vertex == vertex
mask = (EE1 == II).^-1;
% compute minimum distance to any vertex: radius of largest ball
r = min(mask.*DD)./2;
% get the sphere median
rMedian = median(r);
% set up color
c = V*0;
c(r<rMedian,:)=repmat([1 0 0],size(c(r<rMedian,:),1),1);
c(r>=rMedian,:)=repmat([0.5 0.5 0.5],size(c(r>=rMedian,:),1),1);
% Obtain the packing density
density = sum(4/3*pi.*r.^3);
end

% adjust sizes
%r(r<rMedian) = repmat(min(r),size(r(r<rMedian)));
%r(r>=rMedian) = repmat(rMedian,size(r(r>=rMedian)));
% plot mesh and balls
fig3 = figure();
    fig3.Renderer='Painters';
bubbleplot3(V(:,1),V(:,2),V(:,3),r,c)
axis equal
campos([8,-4.5,5])
title(['packing density = ' num2str(density)]);
camlight right; lighting phong;
grid off
box on
xlim([0 1]);
ylim([0 1]);
zlim([0 1]);




function handles = bubbleplot3(x,y,z,r,varargin)
%BUBBLEPLOT3  A simple 3D-bubbleplot.
%     BUBBLEPLOT3() is a three-dimensional bubbleplot.
%   
%     BUBBLEPLOT3(x,y,z,r), where x, y, z and r are four vectors of the 
%     same length, plots bubbles of radii r in 3-space with centers at
%     the points whose coordinates are the elements of x, y and z. If r 
%     is a matrix of size numel(x)x3, BUBBLEPLOT3 produces ellipsoids with
%     centers x(i),y(i),z(i) and radii r(i,1), r(i,2) and r(i,3).
% 
%     BUBBLEPLOT3(x,y,z,r,c), where c is a rgb-triplet array (in [0,1])
%     with numel(x) rows, plots bubbles with colours specified by c.
% 
%     BUBBLEPLOT3(x,y,z,r,c,Alpha), where Alpha is a scalar with value from 
%     0.0 to 1.0, plots bubbles with FaceAlpha Alpha.
% 
%     BUBBLEPLOT3(x,y,z,r,c,Alpha,n,m), where m and n are scalar values that
%     decides the size of the arrays used to render the bubbles. 
%     The largest radius in the set is rendered with (n+1)x(n+1) points.
%     To increase efficiency, the number of rendering points used is 
%     decreasing linearly with the radius but is never rendered with 
%     fewer points than (m+1)x(m+1). 
%     
%     BUBBLEPLOT3(x,y,z,r,c,Alpha,n,m,'PropertyName',PropertyValue,...)
%     Any property-value pair setting valid for a SURFACE object can be
%     passed as optional parameters.
%   
%     BUBBLEPLOT3 returns a column vector of handles to surface objects.
%
%   Example: Three bubbles using your standard colormap
%   
%   x=[0 1 -1];
%   y=[-1 0 1];
%   z=[1 -1 0];
%   r=[.3 .6 .9]
%   bubbleplot3(x,y,z,r,[],[],[],[],'Tag','MyFirstBubbleplot3Bubbles')
%   shading interp; camlight right; lighting phong; view(60,30);
%   
%   See also scatter3 surface surf plot3 scatter 


% Author: Peter (PB) Bodin
% Email: pbodin@kth.se
% Created: 06-Aug-2005 14:02:27


msgstruct = nargchk(0,1,nargout,'struct');
error(msgstruct);
if nargin > 8 
    [xargs{1:nargin-8}]=varargin{5:end};
else
    xargs={};
end
if nargin <8 || isempty(varargin{4}) || varargin{4}<7
    M=10;
else
    M=ceil(varargin{4});
end

if nargin <7 || isempty(varargin{3})
    N=20;
else
    N=floor(varargin{3}); 
end

% Use 3 (N+1)x(N+1) arrays to generate the sphere with the largest radii.
% There´s no need to render the smaller spheres/ellipsoids as detailed as
% the largest one, scale them linearly against R-max. Let the smallest N 
% be M (default 10).

N=ceil(r/norm(r,2)*N/(max(r/norm(r,2))+eps));
N(N<M)=M;
h=zeros(1,numel(x));

% Make sure that x is a column vector, makes it easier to check if the user
% supplied bubble or ellipsoid radiis for x,y,z
x=x(:);

% Set up equal axis, set DoubleBuffer on and add a grid
axis equal;set(gcf,'DoubleBuffer','on');grid on;
for k=1:numel(x)
    if size(r)==[numel(x) 3]
    [X{k},Y{k},Z{k}]=ellipsoid(x(k),y(k),z(k),r(k,1),r(k,2),r(k,3),N(k));
    else 
    [X{k},Y{k},Z{k}]=ellipsoid(x(k),y(k),z(k),r(k),r(k),r(k),N(k));
    end
    h(k)=surface(X{k},Y{k},Z{k},xargs{:});
end

% Set LineStyle to 'none'
[lstyle{1:numel(x),1}]=deal('none'); 
set(h,{'LineStyle'},lstyle); 

% If a color specification is available ...
if numel(varargin)>0 && ~isempty(varargin{1})
    try
        set(h,{'FaceColor'},mat2cell(varargin{1},ones(size(varargin{1},1),1),3));
    catch
        [errmsg,errid]=lasterr;
        error(errmsg);
    end
end

% If Alpha is specified ... 
if numel(varargin)>1 && ~isempty(varargin{2})
    [Alpha_{1:numel(x),1}]=deal(varargin{2});
    try
        set(h,{'FaceAlpha'},Alpha_);
    catch
        [errmsg,errid]=lasterr;
        error(errmsg);
    end
end 

view(3);

% outputs?
if nargout>0
    handles=h';
end

end