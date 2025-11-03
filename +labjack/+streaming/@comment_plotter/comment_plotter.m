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
    %
    %   

    properties
        comments labjack.streaming.comments
        h_axes
        h_axes_text
    end

    methods
        function obj = comment_plotter(h_axes,h_axes_text,comments)
            %
            %   labjack.streaming.comment_plotter(h_axes,h_axes_text,comments)
        end
    end
end