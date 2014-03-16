function hFigure = seqshowlogo(varargin)
%SEQSHOWLOGO displays a Java seqlogo frame in a figure window
isAA = false;
seqType = 'NT';
filename = 'seqlogo.png'; %#ok!
saveLogo = false;%#ok!
wtMatrix = [];
symbols = [];
startPos = 1;

if nargin == 4 % Pass in weight Matrix, list of symbols and isAA
    wtMatrix = varargin{1};
    symbols = varargin{2};
    isAA = varargin{3};
    startPos = varargin{4}; 
elseif nargin == 5 % Pass in weight Matrix, list of symbols, isAA and filename
    saveLogo = true;%#ok!
    wtMatrix = varargin{1};
    symbols = varargin{2};
    isAA = varargin{3};
    startPos = varargin{4}; 
    filename = varargin{5};%#ok!
end

if isAA
    seqType = 'AA';
end

import com.mathworks.toolbox.bioinfo.sequence.*;
import com.mathworks.mwswing.MJScrollPane;
import java.awt.Dimension;
% Create the viewer
logoViewer = SequenceViewer(wtMatrix, symbols,startPos, seqType);
awtinvoke(logoViewer,'addSeqLogo()');
scrollpanel = MJScrollPane(logoViewer, MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,...
                              MJScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);

% Create a figure with the seqlogo panel on it and a uitoolbar
logoContainer = [];
hFigure = figure( ...
            'WindowStyle', 'normal',...
            'Resize', 'on', ...
            'Toolbar', 'none',...
            'NumberTitle','off',...
            'Tag', 'seqlogo',...
            'Name', 'Sequence Logo',...
            'HandleVisibility', 'Callback',...
            'visible', 'off',...
            'DeleteFcn', {@onLogoClosing, logoViewer, logoContainer});
        
initFigureTools(hFigure, logoViewer)

% Set the figure widow size to fit the scrollPane
d = awtinvoke(scrollpanel, 'getPreferredSize()');
pos = getpixelposition(hFigure);
pos(3) = d.getWidth;
pos(4) = d.getHeight;
setpixelposition(hFigure,pos);
[logoP, logoContainer] = javacomponent(scrollpanel, ...
                                       [0, 0, pos(3), pos(4)], hFigure);

set(logoContainer, 'units', 'normalized');
set(hFigure, 'visible', 'on')
end %seqshowlogo
%----------------------------------------------------------------------%
% % Using figure print function instead.
% % function printHandler(hsrc, event,logoViewer) %#ok
% % awtinvoke(logoViewer, 'logoPrint()');

%----------------------------------------------------------------------%
function saveHandler(hsrc, event, logoViewer) %#ok<INUSL>
awtinvoke(logoViewer, 'saveLogoDialog()')
end
%----------------------------------------------------------------------%
function onLogoClosing(hfig, event, logoViewer, logoContainer) %#ok<INUSL>
if ~isempty(logoViewer)
    awtinvoke(logoViewer, 'cleanup()');
    delete(logoContainer);
end
end
%--------------------------------------------------------------------
function initFigureTools(fig, logoViewer)
% helper function to set figure menus and toolbar
oldSH = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')

% Handle toolbar 
toolbarHandle = uitoolbar('parent', fig);
hSave = uitoolfactory(toolbarHandle, 'Standard.SaveFigure');
set(hSave,  'ClickedCallback', {@saveHandler, logoViewer}, 'tooltip', 'Export Logo Image');

hPrint = uitoolfactory(toolbarHandle, 'Standard.PrintFigure');
set(hPrint, 'tooltip', 'Print');

% delete figure menus not used
%h1 = findall(fig,'Type','uimenu', 'Label','&Edit');
h1 = findall(fig,'Type','uimenu', 'Tag','figMenuEdit');
%h2 = findall(fig,'Type','uimenu', 'Label','&View');
h2 = findall(fig,'Type','uimenu', 'Tag','figMenuView');
%h3 = findall(fig,'Type','uimenu', 'Label','&Insert');
h3 = findall(fig,'Type','uimenu', 'Tag','figMenuInsert');
%h4 = findall(fig,'Type','uimenu', 'Label','&Tools');
h4 = findall(fig,'Type','uimenu','Tag','figMenuTools');
%h5 = findall(fig,'Type','uimenu', 'Label','&Desktop');
h5 = findall(fig,'Type','uimenu', 'Tag','figMenuDesktop');
delete([h1,h2,h3,h4,h5])

% Repair "File" menu
%hw = findall(fig,'Type','uimenu', 'Label','&File');
hw = findall(fig,'Type','uimenu', 'Tag','figMenuFile');
hf = get(hw,'children');
%h1 = findall(hw,'Label','&Save');
h1 = findall(hw,'Tag','figMenuFileSave');
%h2 = findall(hw,'Label','Print Pre&view...');
h2 = findall(hw,'Tag','figMenuFilePrintPreview');
%h3 = findall(hw,'Label','&Print...');
h3 = findall(hw,'Tag','printMenu');
%h4 = findall(hw,'Label', '&Close');
h4 = findall(hw,'Tag', 'figMenuFileClose');
delete(setxor(hf,[h1,h2,h3, h4]))

set(h1, 'label', '&Export Logo Image...', 'Callback', {@saveHandler, logoViewer});
set(h1,'Separator','on')

% Repair "Help" menu
%hw = findall(fig,'Type','uimenu','Label','&Help');
hw = findall(fig,'Type','uimenu','Tag','figMenuHelp');
delete(get(hw,'children'));
uimenu(hw,'Label','Bioinformatics Toolbox Help','Position',1,'Callback',...
       'helpview(fullfile(docroot,''toolbox'',''bioinfo'',''bioinfo.map''),''bioinfo_product_page'')')
uimenu(hw,'Label','Examples','Position',2,'Separator','on',...
       'Callback','demo(''toolbox'',''bioinfo'')')   
tlbx = ver('bioinfo');
mailstr = ['web(''mailto:bioinfofeedback@mathworks.com?subject=',...
           'Feedback%20for%20SeqLogo%20in%20Bioinformatics',...
           '%20Toolbox%20',tlbx(1).Version,''')'];
uimenu(hw,'Label','Send Feedback','Position',3,'Separator','on',...
       'Callback',mailstr);

set(0,'ShowHiddenHandles',oldSH)
end