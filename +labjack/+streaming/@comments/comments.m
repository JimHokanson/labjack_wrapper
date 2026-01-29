classdef comments < handle
    %
    %   Class:
    %   labjack.streaming.comments
    %
    %   Held by:
    %   user
    %
    %   See Also
    %   --------
    %   labjack.stream_controller
    %   labjack.streaming.acquired_data

    %{
        msgs = ["test" "one" "two" "three"];
        times = [0.5 1 3 10];
        for i = 1:3
            ax(i) = subplot(3,1,i);
            plot(1:10)
        end
        c = labjack.streaming.comments();
        c.addComments(msgs,times);
        c.enableCommentPlotting(ax);
    %}



    properties (Dependent)
        %cellstr
        values
        times
        ids
        has_save_object
    end

    properties (Hidden)
        h_values = {}
        h_times = []

        %This is currently just 1:n
        h_ids
        h_deleted = false(1,0)
        last_id = 0
        n_comments = 0
        
        %%matlab.io.MatFile or empty
        h_mat

        plotter labjack.streaming.comment_plotter
    end

    methods
        function out = get.values(obj)
            out = obj.h_values(~obj.h_deleted);
        end
        function out = get.times(obj)
            out = obj.h_times(~obj.h_deleted);
        end
        function out = get.ids(obj)
            out = obj.h_ids(~obj.h_deleted);
        end
        function out = get.has_save_object(obj)
            out = ~isempty(obj.h_mat);
        end
    end

    methods
        function obj = comments(h_mat)
            %
            %   comments(*h_mat)
            %
            %   Inputs
            %   ------
            %   h_mat: matlab.io.MatFile
            %   

            if nargin == 0
                h_mat = [];
            end
            obj.h_mat = h_mat;
        end
        function addComments(obj,messages,times)
            %
            %   Inputs
            %   ------
            %   messages : strings or cellstr or char
            %   times : numeric array

            if ischar(messages)
                messages = {messages};
            end
            for i = 1:length(times)
                if iscell(messages)
                    obj.addComment(messages{i},times(i))
                else
                    obj.addComment(messages(i),times(i))
                end
            end
        end
        function addComment(obj,message,time)
            %
            %   For now we'll just grow the arrays. Eventually
            %   we may do better preallocation

            message = char(message);
            obj.h_ids = [obj.h_ids obj.last_id+1];
            obj.h_values = [obj.h_values {message}];
            obj.h_times = [obj.h_times time];
            obj.h_deleted = [obj.h_deleted false];
            obj.last_id = obj.last_id + 1;
            obj.n_comments = obj.n_comments + 1;
            I = obj.last_id;
            obj.saveEntry(I);

            if ~isempty(obj.plotter)
                obj.plotter.renderNewestComment();
            end
        end
        function saveEntry(obj,I)
           if ~isempty(obj.h_mat)
                if I == 1 && obj.last_id == 1
                    obj.h_mat.comments_ids = obj.h_ids;
                    obj.h_mat.comments_values = obj.h_values;
                    obj.h_mat.comments_times = obj.h_times;
                    obj.h_mat.comments_deleted = obj.h_deleted;
                    obj.h_mat.last_id = obj.last_id;
                else
                    obj.h_mat.comments_ids(I,1) = obj.h_ids(I);
                    obj.h_mat.comments_values(I,1) = obj.h_values(I);
                    obj.h_mat.comments_times(I,1) = obj.h_times(I);
                    obj.h_mat.comments_deleted = obj.h_deleted(I);
                    obj.h_mat.last_id = obj.last_id;
                end
            end
        end
        function editCommentText(obj,id,new_text)
            obj.h_values{id} = char(new_text);
            obj.saveEntry(id);
        end
        function moveComment(obj,id,new_time)
            obj.h_times(id) = new_time;
            obj.saveEntry(id);
        end
        function deleteComment(obj,id)
            obj.h_deleted(id) = true;
            obj.saveEntry(id);
        end
        function enableCommentPlotting(obj,h_axes)
            %
            %   h_axes : {axes} or [axes]
            obj.plotter = labjack.streaming.comment_plotter(h_axes,obj);
        end
        function reinitializeAxes(obj,axes_index)
            obj.plotter.rerenderLine(axes_index);
            obj.plotter.renderCommentLines();
        end
    end
end