/**
 * The Shadowbox Flowplayer class.
 *
 * Shadowbox is an online media viewer application that supports all of the
 * web's most popular media publishing formats. Shadowbox is written entirely
 * in JavaScript and CSS and is highly customizable. Using Shadowbox, website
 * authors can showcase a wide assortment of media in all major browsers without
 * navigating users away from the linking page.
 *
 * @author      Maarten Billemont <lhunath@gmail.com>
 * @copyright   2009 Maarten Billemont
 */

function serialize(_obj){
   // Let Gecko browsers do this the easy way
   if (typeof _obj !== 'undefined' && typeof _obj.toSource !== 'undefined' && typeof _obj.callee === 'undefined')
   {
      return _obj.toSource();
   }


   // Other browsers must do it the hard way
   switch (typeof _obj)
   {
      case 'number':
      case 'boolean':
      case 'function':
      case 'string':
         return "'" + _obj + "'";
         break;

      case 'object':
         var str;
         if (_obj.constructor === Array || typeof _obj.callee !== 'undefined')
         {
            str = '[';
            var i, len = _obj.length;
            for (i = 0; i < len-1; i++) { str += serialize(_obj[i]) + ','; }
            str += serialize(_obj[i]) + ']';
         }
         else
         {
            str = '{';
            var key;
            for (key in _obj) { str += "'" + key + "':" + serialize(_obj[key]) + ','; }
            str = str.replace(/\,$/, '') + '}';
         }
         return str;
         break;

      default:
         return "''";
         break;
   }
}

(function(S){

    var U = S.util,
        controller_height = 25; // height of Flowplayer controller

    /**
     * Constructor. This class is used to display Flash videos with Flowplayer.
     *
     * @param   Object      obj     The content object
     * @public
     */
    S.flv = function(obj){
        this.obj = obj;

        // FLV's are resizable
        this.resizable = true;

        // height/width default to 300 pixels
        this.height = obj.height ? parseInt(obj.height, 10) : 300;
        if(S.options.showMovieControls == true)
            this.height += controller_height;
        this.width = obj.width ? parseInt(obj.width, 10) : 300;
    }

    S.flv.prototype = {

        /**
         * Appends this movie to the document.
         *
         * @param   HTMLElement     body    The body element
         * @param   String          id      The content id
         * @param   Object          dims    The current Shadowbox dimensions
         * @return  void
         * @public
         */
        append: function(body, id, dims){
            this.id = id;

            // append temporary content element to replace
            var tmp = document.createElement('div');
            tmp.id = id;
            body.appendChild(tmp);

            var h = dims.resize_h, // use resized dimensions
                w = dims.resize_w,
                swf = S.path + 'libraries/mediaplayer/flowplayer-3.1.1.swf',
                version = S.options.flashVersion,
                express = S.path + 'libraries/swfobject/expressInstall.swf',
                flashvars = U.apply({
                    config:         serialize({
                        buffering:  S.options.buffering? true: false,
                        clip:       {
                            url:        this.obj.content,
                            autoPlay:   S.options.autoplay? true: false
                        },
                        screen: {
                            width:      w,
                            height:     h
                        }
                    })
                }, S.options.flashVars),
                params = S.options.flashParams;

            swfobject.embedSWF(swf, id, w, h, version, express, flashvars, params);
        },

        /**
         * Removes this movie from the document.
         *
         * @return  void
         * @public
         */
        remove: function(){
            // call express install callback here in case express install is
            // active and user has not selected anything
            swfobject.expressInstallCallback();
            swfobject.removeSWF(this.id);
        }
    };

})(Shadowbox);
