// This script was adapted from
// https://github.com/JuliaLang/Interact.jl/blob/master/src/IJulia/ijulia.js
(function (IPython, $) {
    $.event.special.destroyed = {
	remove: function(o) {
	    if (o.handler) {
		o.handler.apply(this, arguments)
	    }
	}
    }

    $(document).ready(function() {
	function initComm(evt, nb) {
	    var comm_manager = nb.kernel.comm_manager;
        console.log("plotly comm init");
	    comm_manager.register_target("plotlyjs_eval", function (comm) {
            comm.on_msg(function (msg) {
                // Call the code in the message
                eval(msg.content.data.code);

                // Clean up
                delete msg.content.data.code;
            });
	    });

        comm_manager.register_target("plotlyjs_return", function (comm) {
            comm.on_msg(function (msg) {
                // Call the code in the message
                val = eval(msg.content.data.code);

                // resolve any promises so we get a raw value
                val === undefined && (val = null);
                if (val && val.constructor == Promise) {
                    val.then(function(real_val) {
                        // Send the value back to Julia
                        comm.send({action: "plotlyjs_ret_val", ret: val});
                    });
                } else {
                    comm.send({action: "plotlyjs_ret_val", ret: val});
                }


                // Clean up
                delete msg.content.data.code;  // clean up
                delete val;
            });
	    });
	}

	try {
	    // try to initialize right away. otherwise, wait on the status_started event.
	    initComm(undefined, IPython.notebook);
	} catch (e) {
        console.log(e);
	    $([IPython.events]).on('kernel_created.Kernel kernel_created.Session', initComm);
	}
    });
})(IPython, jQuery);
