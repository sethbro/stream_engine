package {

    import InfoField;
    import flash.events.ActivityEvent;
    import flash.display.Sprite;

    public class InfoPanel extends Sprite {
        public var fields:Object;

        /**
         * Given an object, creates dynamic label/value textfields for object properties
         */
        public function InfoPanel( fieldArray ) {
            var i, field, prev;

            fields = [];
            for ( i = 0; i < fieldArray.length; i++ ) {
                field = fieldArray[i];
                prev = fieldArray[i-1] || 0;

                fields[field] = new InfoField( field );
                fields[field].y = ( i === 0 ) ? 0 : fields[prev].y + fields[prev].height;
                addChild(fields[field]);
            }
        }
    }
}
