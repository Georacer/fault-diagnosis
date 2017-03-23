=============
Graph display
=============

Structural graphs typically are too large to be inspected as numerical arrays. The ``Plotter`` class allows visualization of a bipartite graph in two ways.

 * ``PlotDM()`` - This method converts the graph into a temporary ``DiagnosisModel`` object (from ``Fault Diagnosis Tooblox``) and uses its ``PlotDM()`` method to present the fine Dulmage-Mendelson decomposition of the system graph.
 * ``plotDot(graphName,compile)`` - This method exports the graph structure into a file written in the ``dot`` language of the GraphViz package. If the ``compile`` argument is true (by default), then it also runs the ``dot`` compiler onto the file and exports a PostScript image in the model description directory.