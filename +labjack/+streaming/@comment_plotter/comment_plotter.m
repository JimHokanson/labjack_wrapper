classdef comment_plotter < handle
    %
    %   Class:
    %   labjack.streaming.comment_plotter
    %
    %   This should generally be accessed via the comments object:
    %   labjack.streaming.comments
    %
    %       c.enableCommentPlotting(ax);
    %   
    %
    %   Functionality
    %   -------------
    %   - plots comments
    %   - allows moving comments (click on the text to move)
    %   - deleting comments
    %   - add comments (how to expose?) (NOT YET IMPLEMENTED)
    %       - eventually have interface
    %       - for now, expect GUI code to handle on its own
    %       - could have a method that you pass a context menu into
    %         that adds a "add comment" box
    %
    %   
    %   Data Model
    %   ----------
    %   - updates here - translate back to comments
    %   - adding comments - assuming (for now) that comments know
    %
    %   OR RATHER - anything graphical, let comments object know
    %       - anything in code, assumes comments object knows
    %
    %
    %   See Also
    %   --------
    %   labjack.streaming.comments
    %
    %
    %   Limitations
    %   -----------
    %   - Currently changes the units of the figure to normalized. This
    %   helps with the annotation markup when moving a line
    %
    %   Improvements
    %   ------------
    %   1) DONE Allow a cell array of axes as an input
    %   2) Make the text axes the bottom one by default
    %   3) Allow aligning text on the top of an axes (for use on the
    %   top most axes)
    %   4) Allow enabling, or maybe enable by default, the better resizing
    %   function. Note, only one callback allowed which is why I haven't
    %   used this (LimitsChangedFcn). In other words, if this class sets
    %   it, then the user can't set it as well.
    %   5) Currently IDs and indices are linked. Ideally we could allow
    %   deleting and still track what is what.
    %   



    %
    %   https://github.com/JimHokanson/interactive_matlab_plot/blob/master/%2Binteractive_plot/%40comments/comments.m
    
    %{
    

    %}


    properties
        %This is the actual data. It is expected that this is created
        %first and then the plotter is retrieved from the data class.
        comments labjack.streaming.comments

        %One line handle per axes
        %Holds vertical line data for all coments, linked by NaN points
        %
        %   This gets rerendered every time lines change
        h_lines
        
        %Cell array, one per text entry
        %
        %   This is only attached to one axes, the "h_axes_text"
        h_text




        h_fig
        h_axes matlab.graphics.axis.Axes
        h_axes_text matlab.graphics.axis.Axes
        y_bottom_axes
        y_top_axes

        %Menus and callbacks
        %----------------
        %First menu item - for showing the name of the selected label
        h_m1  %uimenu
        
        %Handle to the menu for moving and making visible
        h_menu  %uicontextmenu
        selected_line_I
        h_line_temp

        ylim_listener
        fig_size_listener
        
    end

    properties (Dependent)
        strings
        times
        is_deleted
        n_comments
    end

    methods
        function value = get.strings(obj)
            value = obj.comments.h_values;
        end
        function value = get.times(obj)
            value = obj.comments.h_times;
        end
        function value = get.is_deleted(obj)
            value = obj.comments.h_deleted;
        end
        function value = get.n_comments(obj)
            value = obj.comments.n_comments;
        end
        function set.strings(obj,value)
            obj.comments.h_values = value;
        end
        function set.times(obj,value)
            obj.comments.times = value;
        end
        function set.is_deleted(obj,value)
            obj.comments.h_deleted = value;
        end
    end

    methods
        function obj = comment_plotter(h_axes,comments,options)
            %
            %   labjack.streaming.comment_plotter(h_axes,h_axes_text,comments)
            %
            %   Inputs
            %   ------
            %   h_axes: {axes} or [axes] 
            %       All relevant axes. These should generally be stacked.
            %   comments: labjack.streaming.comments

            arguments
                h_axes
                comments
                options.use_ylim_callback = true
            end

            if iscell(h_axes)
                n_cells = length(h_axes);
                h_axes = [h_axes{:}];
                n_axes = length(h_axes);
                if n_axes ~= n_cells
                    error('# of axes changed when collapsing from cell array of axes to axes array')
                end
            end

            obj.h_axes = h_axes;
            obj.comments = comments;
            obj.h_fig = h_axes(1).Parent;

            %Current limitation: ideally we would work around this
            if obj.h_fig.Units ~= "normalized"
                obj.h_fig.Units = "normalized";
            end


            %Establishing top and bottom axes
            %--------------------------------------------------------
            n_axes = length(h_axes);
            y_bottom = zeros(1,n_axes);

            for i = 1:n_axes
                y_bottom(i) = h_axes(i).Position(2);
            end

            [~,I] = max(y_bottom);
            h_top_axes = h_axes(I);
            [~,I] = min(y_bottom);
            h_bottom_axes = h_axes(I);


            obj.h_axes_text = h_bottom_axes;

            p_top = get(h_top_axes,'Position');
            obj.y_top_axes = p_top(2)+p_top(4);
            p_bottom = get(h_bottom_axes,'Position');
            obj.y_bottom_axes = p_bottom(2);

            %Callback for text axes - adjust text position
            %--------------------------------------------------------------
            if options.use_ylim_callback
                %https://www.mathworks.com/matlabcentral/discussions/highlights/134586-new-in-r2021a-limitschangedfcn
                obj.h_axes_text.YAxis.LimitsChangedFcn = @(~,~)obj.ylimChanged;
            else
                %This is not very good but doesn't override the user.
                obj.ylim_listener = addlistener(obj.h_axes_text, 'YLim', ...
                    'PostSet', @(~,~) obj.ylimChanged);
            end


            %Context Menu Setup
            %----------------------------------------
            c = uicontextmenu;
            
            obj.h_m1 = uimenu(c,'label','');
            uimenu(c,'Label','delete comment','Separator','on',...
                'Callback',@(~,~)obj.deleteComment);
            uimenu(c,'Label','edit comment','Callback',@(~,~)obj.editComment);
            
            obj.h_menu = c;
            
            %Initialization of h_line
            %-------------------------------------------
            n_axes = length(obj.h_axes);
            temp = cell(1,n_axes);
            for i = 1:n_axes
                h_axes2 = obj.h_axes(i);
                temp{i} = line(h_axes2,[NaN NaN],[NaN NaN],...
                    'Color',0.5*ones(1,4),'YLimInclude','off');
            end

            obj.h_lines = temp;

            %Initialization of h_text
            %--------------------------------------------
            n_init = 100;
            if obj.n_comments > n_init
                n_init = 2*obj.n_comments;
            end

            obj.h_text = cell(1,n_init);

            %Plotting of initial comments
            %-------------------------------------------------
            obj.renderCommentLines();
            strings2 = obj.strings;
            times2 = obj.times;
            is_deleted2 = obj.is_deleted;
            for i = 1:obj.n_comments
                if ~is_deleted2(i)
                    obj.renderTextEntry(strings2{i},times2(i),i)
                end
            end

        end
        function renderNewestComment(obj)
            %
            %   Assumes a new comment has been added with the comments
            %   object
            I = obj.n_comments;
            msg = obj.strings(I);
            time = obj.times(I);
            obj.renderTextEntry(msg,time,I);
        end
        function renderTextEntry(obj,msg,time,I)
            %TODO: Do a resize check on h_axes
            ylim = obj.h_axes_text.YLim;
            display_string = h__getDisplayString(msg,I);
            obj.h_text{I} = text(obj.h_axes_text,time,ylim(1),display_string,...
                'Rotation',90,'UserData',I,'BackgroundColor',[1 1 1 0.2],...
                'ButtonDownFcn',@(~,~)obj.commentSelected(I));
        end
        function updateTextString(obj,new_msg,I)
            display_string = h__getDisplayString(new_msg,I);
            set(obj.h_text{I},'String',display_string)   
        end
        function renderCommentLines(obj)

            % h_values = obj.comments.h_values;
            h_times = obj.times;

            % h_ids = obj.comments.h_ids;
            h_deleted = obj.is_deleted;
            n_comments2 = obj.n_comments;

            if ~isempty(h_times)
                
                %Line Editing
                %-------------------------------------------
                x = h_times(1:n_comments2);
                %In this way we can track the values, i.e. we
                %never really delete ...
                x(h_deleted(1:n_comments2)) = NaN;
                x_line = NaN(1,3*length(x));
                y1 = -1e9;
                y2 = 1e9;
                y_line = NaN(1,3*length(x));
                
                x_line(1:3:end) = x;
                x_line(2:3:end) = x;
                y_line(1:3:end) = y1;
                y_line(2:3:end) = y2;
                
                
                n_axes = length(obj.h_axes);
                for i = 1:n_axes
                    h_line = obj.h_lines{i};
                    set(h_line,'XData',x_line);
                    set(h_line,'YData',y_line);
                end
            end
        end
        function ylimChanged(obj)
            %
            %   We need to adjust all of the text positions because the
            %   text is placed in axes coordinates.
            
            ylim = get(obj.h_axes_text,'YLim');
            for i = 1:obj.n_comments
                obj.h_text{i}.Position(2) = ylim(1);
            end
        end
    end


    %Interacting with the line
    %--------------------------------------------------------------
    methods
        function rightClickComment(obj)
            %
            %
            %   When right clicking, show the uicontextmenu
            %
            %   Options
            %   -------
            %   - delete
            %   - edit text
            %
            %   Format:
            %   1 - show the selected string
            %   2... - show the action options

            [x,y] = h__getCurrentMousePoint(...
                obj.h_fig,'pixels',true);

            I = obj.selected_line_I;
            string = obj.strings{I};
            display_string = h__getDisplayString(string,I);
            if length(display_string) > 20
                display_string = display_string(1:20);
                display_string(18:20) = '...';
            end

            drawnow('nocallbacks')
            set(obj.h_m1,'Label',display_string);
            set(obj.h_menu,'Position',[x y],'Visible','on')
            drawnow('nocallbacks')

            %Would this be better?
            %refreshdata(obj.h_menu)
        end
        function editComment(obj)
            %
            %  OLD - from IP
            %
            I = obj.selected_line_I;
            options.Resize='on';
            options.WindowStyle='normal';
            %options.Interpreter='tex';

            %Must be a cell array
            default_answer = obj.strings(I);
            answer = inputdlg('Enter new value','Edit Comment',1,default_answer,options);
            if isempty(answer)
                %empty answer indicates canceling
                return
            end

            new_string = answer{1};
            
            obj.comments.editCommentText(I,new_string);

            %TODO: call the method
            obj.updateTextString(new_string,I);

            % %Notify everyone
            % %-----------------------------------
            % s = struct;
            % s.new_string = new_string;
            % s.comment_index = I;
            % obj.commentsUpdated('comment_edited',s)
        end
        function deleteComment(obj)
            I = obj.selected_line_I;

            obj.comments.deleteComment(I);
            % obj.is_deleted(I) = true;
            
            set(obj.h_text{I},'Visible','off')
            obj.renderCommentLines();
            
            % %Notify everyone
            % %-----------------------------------
            % s = struct;
            % s.comment_index = I;
            % obj.commentsUpdated('comment_deleted',s)
        end
        function commentSelected(obj,I)
            %
            %   Mouse clicked on a comment ...
            %
            %   Funtionality
            %   ------------
            %   left click - drag to move
            %   right click - menu option
            
            %Set internal state ----------
            obj.selected_line_I = I;
            
            %Look for right-click
            %- Unfortunately, the right click seems to not be specific
            %- https://www.mathworks.com/help/releases/R2014a/matlab/ref/figure_props.html#SelectionType
            if strcmp(get(obj.h_fig,'SelectionType'),'alt')
                obj.rightClickComment();
                return
            end
            
            %Normal clicking - select for moving
            %------------------------------------------------------
            %On clicking, create a line that represents the location of the
            %comment
            
            x = h__getCurrentMousePoint(obj.h_fig);
            y_line = [obj.y_bottom_axes obj.y_top_axes];
            obj.h_line_temp = annotation('line',[x x],y_line,'Color','r');
            
            set(obj.h_fig, 'WindowButtonMotionFcn',@(~,~)obj.movingComment);
            set(obj.h_fig, 'WindowButtonUpFcn',@(~,~)obj.mouseUp);
            
            % obj.mouse_man.setMouseMotionFunction(@obj.movingComment);
            % obj.mouse_man.setMouseUpFunction(@obj.mouseUp);
        end
        function movingComment(obj)
            %
            %   mouse moved, update position of the comment line
            h = obj.h_text{obj.selected_line_I};
            set(h,'Color','r')
            x = h__getCurrentMousePoint(obj.h_fig);
            set(obj.h_line_temp,'X',[x x]);
        end
        function mouseUp(obj)
            %
            %   mouse released, move comment to location of the mouse
            
            h = obj.h_text{obj.selected_line_I};
            
            %Update time based on mouse
            %------------------------------------
            x_line = get(obj.h_line_temp,'X');
            new_time = h__translateXFromFigToAxes(obj.h_axes_text,x_line(1));
            
            obj.comments.moveComment(obj.selected_line_I,new_time)
            % obj.times(obj.selected_line_I) = new_time;
            
            %Move text and reset text color
            %--------------------------------------
            set(h,'Color','k')
            obj.h_text{obj.selected_line_I}.Position(1) = new_time;
            
            delete(obj.h_line_temp);
            
            set(obj.h_fig,'WindowButtonUpFcn','');
            set(obj.h_fig,'WindowButtonMotionFcn','');
            % obj.mouse_man.initDefaultState();
            
            obj.renderCommentLines();
            
            % % %Notify everyone
            % % %-----------------------------------
            % % s = struct;
            % % s.new_time = new_time;
            % % s.comment_index = obj.selected_line_I;
            % % obj.commentsUpdated('comment_moved',s)
        end
    end
end

function [x,y] = h__getCurrentMousePoint(fig_handle,varargin)
%
%   [x,y] = interactive_plot.utils.getCurrentMousePoint(fig_handle,varargin)
%
%   Optional Inputs
%   ---------------
%   pixels : default false

%We currently assume that we are working with normalized units

in.pixels = false;
in = interactive_plot.sl.in.processVarargin(in,varargin);

cur_mouse_coords = get(fig_handle, 'CurrentPoint');
y = cur_mouse_coords(2);
x = cur_mouse_coords(1);
if in.pixels
    p = getpixelposition(fig_handle);
    y = p(4)*y;
    x = p(3)*x;
end

end

function x_axes = h__translateXFromFigToAxes(h_axes,x_fig)
%
%   x_axes = interactive_plot.utils.translateXFromFigToAxes(h_axes,x_fig)

xlim = get(h_axes,'XLim');

p_axes = get(h_axes,'position');
            
x1 = p_axes(1);
x2 = p_axes(1)+p_axes(3);
y1 = xlim(1);
y2 = xlim(2);

m = (y2 - y1)./(x2 - x1);
b = y2 - m*x2;

x_axes = m*x_fig + b;  

end


function display_string = h__getDisplayString(string,I)
    display_string = sprintf(' %d) %s',I,string);
end