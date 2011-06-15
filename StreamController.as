package {

    import StreamView;
    import StreamConnection;
    import InputController;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.media.Video;
    import flash.media.Camera;
    import flash.external.ExternalInterface;

    public class StreamController extends EventDispatcher {

        var queue:Object;
        var connections:Object;
        public var input:InputController;
        var view:StreamView;
        var clock:Timer;

        const STREAM_EXT = 'sdp';

        /**
         * Starts/stops individual streams and coordinates behaviors between them.
         */
        public function StreamController( viewObj, inputCtrl:InputController=null ) {
            view = viewObj;
            input = inputCtrl || new InputController();
            connections = {};
            queue = {};
            setClock();
        }

        /**
        * Establishes a named 2-way stream connection
        */
        function addConnection( connName, src, dest ) {
            var conn = connections[connName] = new StreamConnection( connName, src, dest, input );

            conn.addEventListener( NetStatusEvent.NET_STATUS, monitor );

            conn.addEventListener( StreamConnection.DISCONNECTED, monitor );
            conn.addEventListener( StreamConnection.CONNECTED, monitor );
            conn.addEventListener( StreamConnection.STREAM_READY, monitor );
            conn.addEventListener( StreamConnection.STREAMING, monitor );
        }

        /**
        * Removes a connection entirely
        */
        function dropConnection( connName ) {
            trace('** Dropping connection', connName );

            stop( connName );
            delete connections[connName];
        }

        /**
        * Publishes stream from source and plays stream at dest
        */
        public function start( connName, streamName='' ) {
            var conn = connections[connName],
                type = conn.types
            ;

            if ( ! conn.streamName ) {
                conn.streamName = streamName || connName + '.' + STREAM_EXT;
                trace('conn.streamName', conn.streamName.toString() );
            }

            trace( '** Starting stream', streamName, 'on connection', connName );
            if ( conn.status !== StreamConnection.STREAM_READY ) {
                trace( '* Stream ', connName, 'not ready. Queuing.' );
                queueStream( connName );
                return;
            }

            //  Cam --> local video
            if ( conn.sourceIsDevice() && type.dest === 'Video' ) {
                trace('connecting', conn.dest, conn.source);
                conn.dest.attachCamera( conn.source );
                //conn.dest.attachAudio( conn.source );
            }
            //  Cam --> media server
            else if ( conn.sourceIsDevice() && type.dest === 'Remote' ) {
                conn.stream.attachCamera( conn.source );
                //conn.stream.attachAudio( conn.source );
                conn.stream.publish( conn.streamName );
            }
            //  TODO: Can three below can be consolidated?
            //  Media server --> local video
            else if ( type.source === 'Remote' && type.dest === 'Video' ) {
                conn.dest.attachNetStream( conn.stream );
                conn.stream.play( conn.streamName );
            }
            //  Local file --> local video
            else if ( type.source === 'Local' && type.dest === 'Video' ) {
                conn.dest.attachNetStream( conn.stream );
                conn.stream.play( conn.streamName );
            }
            //  Local file --> media server
            else if ( type.source === 'Local' && type.dest === 'Remote' ) {
                conn.dest.attachNetStream( conn.stream );
                conn.stream.play( conn.streamName );
            }

            conn.status = StreamConnection.STREAMING;
        }

        /**
        * Stops stream at both ends
        */
        public function stop( connName, streamName='' ) {
            var conn = connections[connName],
                type = conn.types
            ;

            trace( '** Stopping stream', streamName, 'on connection', connName );
            if ( conn.status !== StreamConnection.STREAMING ) {
                trace( '* Stream ', connName, 'not streaming? Not cool.');
            }

            //  Cam -> local video
            if ( conn.sourceIsDevice() && type.dest === 'Video' ) {
                conn.dest.attachCamera( false );
                //conn.dest.attachAudio( false );
            }
            //  Cam -> media server
            else if ( conn.sourceIsDevice() && type.dest === 'Remote' ) {
                conn.stream.attachCamera( false );
                //conn.stream.attachAudio( false );
                conn.stream.publish( false );
            }
            //  Remote -> Video | Local -> Video | Local -> Remote
            else {
                conn.dest.attachNetStream( false );
                conn.stream.close( conn.streamName );
            };

            conn.status = StreamConnection.STREAM_READY;
        }

        /**
         * Sends metadata to an active stream
         */
        function sendData( connName, data ) {
            connections[connName].stream.send( "@setDataFrame", "onMetaData", data );
        }

        /**
         *  Removes connection and places it in queue.
         *  Connection should have a stream object before this point.
         */
        function queueStream( connName ) {
            queue[connName] = connections[connName];
            delete connections[connName];
            trace( '*', connName, 'stream queued' );
        }

        /**
         *  Transfers queued stream into active connections and starts.
         */
        function startQueuedStream( connName, checkSources=true ) {
            var connName, queuedConn,
                toDelete = []
            ;

            trace( '* Start queued connection', connName );
            if ( ! queue[connName] ) {
                return; }

            connections[connName] = queue[connName];
            delete queue[connName];
            trace( '* Unqueued', connName );

            if ( checkSources && queue.length > 0 ) {
                startAllStreamsUsingSource( connections[connName].source );
            }
            start( connName );
        }

        /**
         *  Starts any streams using the specified source.
         */
        function startAllStreamsUsingSource( src ) {
            var conn;

            for ( conn in queue ) {
                if ( conn.source == src ) {
                    startQueuedStream( conn.name, false );
                }
            }
        }

        /**
         * Simple timer used to regularly broadcast network status
         */
        function setClock( interval=1000 ) {
            clock = new Timer( interval );
            if ( input.cam ) {
                clock.addEventListener( TimerEvent.TIMER, view.updateCamInfo );
            }
            clock.addEventListener( TimerEvent.TIMER, broadcastConnStatus );
            clock.start();
        }

        /**
         * Sends network status updates to view
         */
        function broadcastConnStatus( evt:TimerEvent ):void {
            var conn;

            for ( conn in connections ) {
                view.updateStreamInfo( connections[conn] );
                /*ExternalInterface.call( 'tweetOff.streamDriver.updateStatus', connections[conn].status );*/
            }
        }

        /**
         * Monitors StreamConnection and NetStatus events
         */
        function monitor( evt:* ) {
            var connName = evt.target.name;

            if ( evt.type === StreamConnection.STREAM_READY ) {
                trace( '** STREAM READY', evt.target.name, '|', evt.target );
                ( queue[connName] ) ? startQueuedStream( connName ) : start( connName );
            }
            else if ( evt.type === NetStatusEvent.NET_STATUS ) {
                if ( evt.info.level === 'error' ) {
                    handleConnectionError( evt );
                }
                //  Broadcast to javascript
                ExternalInterface.call( driverCall( 'streamMonitor' ), connName, evt.info );
            }
        }

        function handleConnectionError( evt:NetStatusEvent ) {
            // Connection.Failed
            // Connection.Rejected
            // Record.Failed
            // Record.NoAccess
            // Publish.BadName - shouldn't come up if stream naming conventions are strong
        }

        function driverCall( method ) {
            return view.options.driver + '.' + method;
        }
    }
}
