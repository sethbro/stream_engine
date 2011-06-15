package  {

    import StreamView;
    import flash.media.Camera;
    import flash.external.ExternalInterface;

    public class StreamEngine extends StreamView {
        var local = 'cam_local';
        var remote = 'cam_server';

        /**
         *  Initialize video displays. Override for class variants.
         */
        override public function initView() {
            displays = {};

            displays[local] = new StreamDisplay( local, { show_info: false } );
            addChild( displays[local].vid );
        }

        /**
         *  Initialize connections. Override for class variants.
         */
        override public function initConnections() {
            ctrl = new StreamController( this );

            ctrl.addConnection( local, ctrl.input.cam, displays[local].vid );
            //ctrl.start( local );

            ctrl.addConnection( remote, ctrl.input.cam, options.serverURL );
            //ctrl.start( remote, options.streamName );

            // Add JS callbacks
            ExternalInterface.addCallback( 'startRecording', function() {
                ctrl.start( local );
                ctrl.start( remote ) ;
            });

            ExternalInterface.addCallback( 'stopRecording', function() {
                ctrl.stop( local );
                ctrl.stop( remote );
            });
        }
    }
}
