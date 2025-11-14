classdef comment_plotter < handle
    %
    %   Class:
    %   labjack.streaming.comment_plotter
    %
    %   TODO: Get this from the comments as a method
    %
    %   getCommentPlotter(pass_in_constructor_vars)
    %
    %   Functionality
    %   -------------
    %   - plot comments
    %   - move comments
    %   - add comments (how to expose?)
    %       - eventually have interface
    %       - for now, expect GUI code to handle on its own
    %       - could have a method that you pass a context menu into
    %         that adds a "add comment" box
    %
    %   See Also
    %   --------
    %   labjack.streaming.comments
    %
    %   https://github.com/JimHokanson/interactive_matlab_plot/blob/master/%2Binteractive_plot/%40comments/comments.m
    
    %{
    

    %}


    properties
        comments labjack.streaming.comments

        %One line handle per axes
        %Holds vertical line data for all coments, linked by NaN points
        h_lines
        
        %Cell array, one per text entry
        h_text

        %First menu item - for showing the name of the selected label
        h_m1  %uimenu
        
        %Handle to the menu for moving and making visible
        h_menu  %uicontextmenu


        h_fig
        h_axes
        h_axes_text

        %Callbacks
        %----------------
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
        function obj = comment_plotter(h_axes,h_axes_text,comments)
            %
            %   labjack.streaming.comment_plotter(h_axes,h_axes_text,comments)
            %
            %   h_axes - all relevant axes
            %   h_axes_text - axes that will plot the text

            obj.h_axes = h_axes;
            obj.h_axes_text = h_axes_text;
            obj.comments = comments;
            obj.h_fig = h_axes(1).Parent;

            obj.ylim_listener = addlistener(obj.h_axes_text, 'YLim', ...
                'PostSet', @(~,~) obj.ylimChanged);
            % obj.fig_size_listener = addlistener(obj.h_axes_text, 'Position', ...
            %     'PostSet', @(~,~) obj.ylimChanged);

            c = uicontextmenu;
            
            obj.h_m1 = uimenu(c,'label','');
            uimenu(c,'Label','delete comment','Separator','on',...
                'Callback',@(~,~)obj.deleteComment);
            uimenu(c,'Label','edit comment','Callback',@(~,~)obj.editComment);
            
            obj.h_menu = c;
            
            n_axes = length(obj.h_axes);
            temp = cell(1,n_axes);
            for i = 1:n_axes
                h_axes2 = obj.h_axes(i);
                temp{i} = line(h_axes2,[NaN NaN],[NaN NaN],...
                    'Color',0.5*ones(1,4),'YLimInclude','off');
            end

            obj.h_lines = temp;

            n_init = 100;
            if obj.n_comments > n_init
                n_init = 2*obj.n_comments;
            end

            obj.h_text = cell(1,n_init);

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
        function renderTextEntry(obj,msg,time,I)
            ylim = obj.h_axes_text.YLim;
            display_string = h__getDisplayString(msg,I);
            obj.h_text{I} = text(obj.h_axes_text,time,ylim(1),display_string,...
                'Rotation',90,'UserData',I,'BackgroundColor',[1 1 1 0.2],...
                'ButtonDownFcn',@(~,~)obj.commentSelected(I));
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
            
            disp('I ran')
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
            obj.strings{I} = new_string;
            display_string = h__getDisplayString(new_string,I);
            set(obj.h_text{I},'String',display_string)

            %Notify everyone
            %-----------------------------------
            s = struct;
            s.new_string = new_string;
            s.comment_index = I;
            obj.commentsUpdated('comment_edited',s)
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
            
            %JAH AT THIS POINT

            keyboard
            obj.mouse_man.setMouseMotionFunction(@obj.movingComment);
            obj.mouse_man.setMouseUpFunction(@obj.mouseUp);
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
            new_time = interactive_plot.utils.translateXFromFigToAxes(...
                obj.bottom_axes,x_line(1));
            
            obj.times(obj.selected_line_I) = new_time;
            
            %Move tet and reset text color
            %--------------------------------------
            set(h,'Color','k')
            obj.h_text{obj.selected_line_I}.Position(1) = new_time;
            
            delete(obj.h_line_temp);
            
            obj.mouse_man.initDefaultState();
            
            obj.renderComments();
            
            %Notify everyone
            %-----------------------------------
            s = struct;
            s.new_time = new_time;
            s.comment_index = obj.selected_line_I;
            obj.commentsUpdated('comment_moved',s)
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

function display_string = h__getDisplayString(string,I)
    display_string = sprintf(' %d) %s',I,string);
end