package {

    import flash.display.MovieClip;
    import flash.text.TextField;

    public class InfoField extends MovieClip {

        /**
         * Paired label/value textfields
         */
        public function InfoField( name, init='' ) {
            label.text = name;
            value.text = init;
        }

        public function update( val ) {
            value.text = val;
        }
    }
}
