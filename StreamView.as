package {

    import Utils;
    import InfoField;
    import InfoPanel;
    import StreamDisplay;
    import StreamController;

    import flash.events.TimerEvent;
    import flash.display.Sprite;
    import flash.external.ExternalInterface;

    public class StreamView extends Sprite {

        var displays:Object;
        var ctrl:StreamController;
        var camInfoPanel:InfoPanel;
        var serverURL:String;
        var streamName:String;
        var defaults:Object;
        var options:Object;


        /**
         *  Root display for streaming app
         */
        public function StreamView() {

            defaults = {
                driver  : 'tweetOff.streamDriver',
                streamName  : "test_" + new Date().valueOf(),
                protocol: 'rtmp',
                host    : 'ec2-184-72-155-173.compute-1.amazonaws.com',
                app     : 'anything_you_can_tweet',
                showInfo: true,
                padding : 0,
                display : {
                    w: 480,
                    h: 360
                }
            };
            options = Utils.extend( defaults, stage.loaderInfo.parameters );

            var a;
            trace('== options ==');
            for each (a in options) {
                trace(a);
            }
            options.serverURL = setServerURL();

            initView();
            initConnections();
        }

        /**
         *  Initialize video displays. Override for class variants.
         */
        public function initView() {
            /*displays = {};

            displays[options.streamName] = new StreamDisplay( options.streamName, { show_info: false } );
            addChild( displays[options.streamName] );*/
        }

        /**
         *  Initialize connections. Override for class variants.
         */
        public function initConnections() {
            /*ctrl = new StreamController( this );

            ctrl.addConnection( options.streamName, ctrl.input.cam, displays[options.streamName].vid );
            ctrl.start( options.streamName, { show_info : false } );

            ctrl.addConnection( options.streamName, ctrl.input.cam, serverURL );
            ctrl.start( options.streamName, options.streamName );*/
        }

        function positionVid() {

        }

        /**
         *  Creates and places info panel for input devices
         */
        function initCamInfoPanel( x=0, y=0, parent=null ) {
            camInfoPanel = new InfoPanel( [
                "activityLevel",
                "bandwidth",
                "currentFPS",
                "keyFrameInterval",
                "loopback",
                "motionLevel",
                "motionTimeout",
                "quality"
            ] );

            camInfoPanel.x = x;
            camInfoPanel.y = y;

            ( parent ) ? parent.addChild( camInfoPanel ) : addChild( camInfoPanel );
        }

        /**
         *  Creates full media server url from options
         *  TODO - Have StreamController do this
         */
        function setServerURL() {
            var url = [options.protocol, '://', options.host, '/', options.app ].join('');
            trace( 'server url =', url );
            return url;
        }

        /**
         *  Updates info for devices
         *  TODO - Pass cam info in rather than accessing through controller
         */
        public function updateCamInfo( evt:TimerEvent ) {
            var field, panel,
                cam = ctrl.input.cam
            ;

            if ( ! cam || ! camInfoPanel ) {
                return; }

            panel = camInfoPanel.fields
            for ( field in panel ) {
                if ( cam[field] ) {
                    panel[field].value.text = cam[field];
                }
            }
        }

        /**
         *  Updates network status info panels
         */
        public function updateStreamInfo( conn ) {
            var field, panel,
                display = displays[conn.name]
            ;

            if ( ! display || ( display && ! display.infoPanel ) || ! conn.stream ) {
                return;
            }

            panel = display.infoPanel.fields;
            for ( field in panel ) {
                panel[field].value.text = conn.stream[field];
            }
        }
    }
}
