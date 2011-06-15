package {
    public class Utils {

        public static function extend( defaults, overrides ) {
            var d, o={};

            for ( d in defaults ) {
                o[d] = ( overrides[d] === undefined ) ? defaults[d] : overrides[d];
            }

            return o;
        }

        public static function nextX( prevElement, gutterWidth=0 ) {
            return prevElement.x + prevElement.width + gutterWidth;
        }

        public static function nextY( prevElement, gutterWidth=0 ) {
            return prevElement.y + prevElement.height + gutterWidth;
        }
    }
}
