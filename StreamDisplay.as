package {

    import Utils;
    import InfoField;
    import InfoPanel;
    import StreamController;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.media.Video;

    public class StreamDisplay extends Sprite {
        var options:Object = {};
        var defaults:Object;
        public var vid:Video;
        public var infoPanel:InfoPanel;

        public function StreamDisplay( name, opts=null ) {

            defaults = {
                 width      : 480,
                 height     : 360,
                 show_info  : false,
                 fields     :  [
                     "bufferLength",
                     "bufferTime",
                     "bytesLoaded",
                     "bytesTotal",
                     "currentFPS",
                     "liveDelay",
                     "objectEncoding",
                     "time"
                 ]
            };

            opts = opts || {};
            options = Utils.extend( defaults, opts );

            vid = new Video( options.width, options.height );
            addChild( vid );

            if ( options.show_info && options.fields ) {
                infoPanel = new InfoPanel( options.fields );
                infoPanel.x = options.width + 10;
                /*infoPanel.y = titleHeight;*/
                addChild( infoPanel );
            }
        }
    }
}
