package {

    import InputController;

    import flash.events.Event;
    import flash.net.NetStream;
    import flash.net.NetConnection;
    import flash.events.StatusEvent;
    import flash.events.NetStatusEvent;
    import flash.events.ActivityEvent;
    import flash.events.SecurityErrorEvent;
    import flash.external.ExternalInterface;
    import flash.utils.*;


    public class StreamConnection extends NetConnection {

        public static const DISCONNECTED = 'disconnected';
        public static const CONNECTED = 'connected';
        public static const STREAM_READY = 'stream_ready';
        public static const STREAMING = 'streaming';

        public var name:String;
        public var source;
        public var dest;
        public var stream:NetStream;
        public var streamName:String;
        public var types:Object;
        public var status:String;
        public var input:InputController;

        private var options:Object;


        /**
         * Initiates, monitors and maintains a single network onnection,
         * as well as any NetStreams established over that connection.
         * Acts as facade for local/device connections to use same API.
         */
        public function StreamConnection( connName, src, dest, inputCtrl ) {

            name = connName;
            source = src;
            this.dest = dest;
            input = inputCtrl;
            status = StreamConnection.DISCONNECTED;
            types = {
                source  : determineResourceType( source ),
                dest    : determineResourceType( dest )
            };

            trace( '** Adding connection ', connName, types.source, '-->', types.dest );
            initConnection();
        }

        /**
         * Initiates network connection if needed and sets listeners
         */
        function initConnection() {
            var netConnRequired = true;

            if ( sourceIsDevice() ) {
                netConnRequired = connectDevice();

                if ( ! netConnRequired ) {
                    return; }
            }

            addEventListener( NetStatusEvent.NET_STATUS, netMonitor );
            addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityMonitor );

            if ( types.source === 'Remote' ) {
                connect( source );
            }
            else if ( types.dest === 'Remote' ) {
                connect( dest );
            }
            else {
                connect( null ); // Local
            }
        }

        /**
         * Initiates "connection" when one end is a cam/mic
         */
        function connectDevice() {
            source.addEventListener( StatusEvent.STATUS, deviceMonitor );

            if ( ! input.activated() ) {
                input.askPermission();
            }

            if ( types.dest === 'Video' ) {
                initializeStream();
                return false;
            }
            else {
                return true;
            }
        }

        /**
         * Establishes a ready-to-play network stream and announces same.
         */
        function initializeStream() {
            trace( '* Initializing stream for', name );
            if ( sourceIsDevice() ) {
                initializeDeviceStream();
            }
            else {
                stream = new NetStream( this );
                stream.addEventListener( NetStatusEvent.NET_STATUS, netMonitor );
                trace( 'Empty stream initialized for', name );

                status = StreamConnection.STREAM_READY;
                dispatchEvent( new Event( StreamConnection.STREAM_READY ));
            }
        }

        /**
         * Establishes stream for cam/mic if destination is not local
         */
        function initializeDeviceStream() {
            if ( source.muted ) {
                return; }

            if ( types.dest != 'Video' ) {
                stream = new NetStream( this );
                stream.addEventListener( NetStatusEvent.NET_STATUS, netMonitor );
                trace( 'Empty stream initialized for', name );
            }

            status = StreamConnection.STREAM_READY;
            dispatchEvent( new Event( StreamConnection.STREAM_READY ));
        }

        /**
         * Monitors all network events for the connection and acts accordingly.
         */
        function netMonitor( evt ):void {
            trace( '* Net event on', name, '|', evt.info.code );
            //ExternalInterface.call( 'tweetOff.streamDriver.updateStatus', name, evt.info );

            switch ( evt.info.code ) {
                case "NetConnection.Connect.Success":
                    status = StreamConnection.CONNECTED;
                    initializeStream();
                    break;

                case "NetStream.Play.StreamNotFound":
                    trace( "Stream not found: " + streamName );
                    break;
            }
        }

        /**
         * Monitors cam/mic access and "connects" devices when they become available
         */
        function deviceMonitor( evt:StatusEvent ):void {
            trace( '* Activity on device', evt.target, '|', evt.code );
            if ( evt.code.search( 'Unmuted' ) > -1 ) {
                initializeStream();
            }
        }

        function securityMonitor( event:SecurityErrorEvent ):void {
            trace("securityErrorHandler: ", event );
        }

        function sourceIsDevice() {
            return ( ["Camera", "Microphone"].indexOf( types.source ) !== -1 );
        }

        /**
         *  cam     - Camera
         *  mic     - Microphone
         *  local   - 'local/path/to/file'
         *  network - 'protocol:[//host][:port]/appname[/instanceName]'
         */
        private function determineResourceType( obj ) {
            var type = getQualifiedClassName( obj ).split('::').pop();

            trace(obj, type);
            if ( type === 'String' ) {
                type = ( obj.search('://') === -1 ) ? 'Local' : 'Remote';
            }

            return type;
        }
    }
}
