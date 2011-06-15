package {

    import flash.media.Camera;
    import flash.media.Microphone;
    import flash.events.StatusEvent;
    import flash.events.ActivityEvent;
    import flash.events.EventDispatcher;
    import flash.system.SecurityPanel;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.system.Security;


    public class InputController extends EventDispatcher {

        public var cam:Camera;
        public var mic:Microphone;
        public var clock:Timer;
        var camFields = ["activityLevel", "bandwidth", "currentFPS", "keyFrameInterval", "loopback", "motionLevel", "motionTimeout", "quality"];

        /**
         * Registers and controlls all camera and microphone devices
         * TODO - pretty much all audio handling
         */
        public function InputController( activate=true ) {
            if ( activate ) {
                activateInputs();
            }
        }

        /**
         * Activates any cams/mics on the computer
         * TODO - Handling for edge case of multiple devices
         */
        function activateInputs( video=true, audio=true ) {

            if ( video ) {
                cam = Camera.getCamera();
                trace( 'Cam instantiated, muted =', cam.muted );
                if ( ! cam ) {
                    noInputError( 'camera' );
                }
                else {
                    cam.addEventListener( StatusEvent.STATUS, deviceMonitor );
                    cam.addEventListener( ActivityEvent.ACTIVITY, activityMonitor );
                }
            }

            if ( audio ) {
                mic = Microphone.getMicrophone();
                trace( 'mic instantiated, muted = ', mic.muted );

                if ( ! mic ) {
                    noInputError( 'microphone' );
                }
                else {
                    mic.addEventListener( StatusEvent.STATUS, deviceMonitor );
                    mic.addEventListener( ActivityEvent.ACTIVITY, activityMonitor );
                }
            }
        }

        /**
         * Displays Flash privacy permissions dialog
         */
        public function askPermission() {
            Security.showSettings( SecurityPanel.PRIVACY );
        }

        public function activated() {
            return ( ! cam.muted && ! mic.muted );
        }

        private function deviceMonitor( evt:StatusEvent ):void {
            trace( '* Device event |', evt );
        }

        private function infoMonitor( evt:TimerEvent ):void {
            // Info!
        }

        private function activityMonitor( evt:ActivityEvent ):void {
            // Activity!
        }

        private function noInputError( device ) {
            trace( 'No ', device, '  installed!' );
        }
    }
}

/*
const DELAY_LENGTH:int = 4000;
var mic:Microphone = Microphone.getMicrophone();
mic.setSilenceLevel(0, DELAY_LENGTH );
mic.gain = 100;

mic.rate = 44;
mic.addEventListener( SampleDataEvent.SAMPLE_DATA, micSampleDataHandler );

var mic_timer:Timer = new Timer( DELAY_LENGTH );
mic_timer.addEventListener( TimerEvent.TIMER, micTimerHandler );
mic_timer.start();

function micSampleDataHandler( event:SampleDataEvent ):void
{
  while( event.data.bytesAvailable )
  {
      var sample:Number = event.data.readFloat();
      soundBytes.writeFloat( sample );
  }
}

function micTimerHandler( event:TimerEvent ):void
{
  mic.removeEventListener( SampleDataEvent.SAMPLE_DATA, micSampleDataHandler );
  mic_timer.stop();
  soundBytes.position = 0;
  var sound:Sound = new Sound();
  sound.addEventListener( SampleDataEvent.SAMPLE_DATA, playbackSampleHandler );
  sound.play();
}

function playbackSampleHandler( event:SampleDataEvent ):void
{
  for ( var i:int = 0; i < 8192 && soundBytes.bytesAvailable > 0; i++)
  {
      trace( sample );
      var sample:Number = soundBytes.readFloat();
      event.data.writeFloat( sample );
      event.data.writeFloat( sample );
  }
}*/
