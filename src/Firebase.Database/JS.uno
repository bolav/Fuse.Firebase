using Uno;
using Uno.UX;
using Uno.Threading;
using Uno.Text;
using Uno.Platform;
using Uno.Compiler.ExportTargetInterop;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Firebase.Database;

namespace Firebase.Database.JS
{
	/**
	*/
	[UXGlobalModule]
	public sealed class DatabaseModule : NativeEventEmitterModule
	{
		static readonly DatabaseModule _instance;

		public DatabaseModule() : base(false,"data")
		{
			if(_instance != null) return;
			Resource.SetGlobalKey(_instance = this, "Firebase/Database");

            DatabaseService.Init();
            // AddMember(new NativeFunction("logIt", LogIt));
			var onData = new NativeEvent("onData");
			On("data", onData);

			AddMember(onData);
			AddMember(new NativeFunction("listen", (NativeCallback)Listen));
            AddMember(new NativePromise<string, string>("read", Read, null));
            AddMember(new NativeFunction("push", (NativeCallback)Push));
            AddMember(new NativeFunction("save", (NativeCallback)Save));
		}

        static Future<string> Read(object[] args)
        {
            var path = args[0].ToString();
            return new Read(path);
        }

        object Push(Fuse.Scripting.Context context, object[] args)
        {
            var path = args[0].ToString();
            if (args[1] is Fuse.Scripting.Object) {
                var p = (Fuse.Scripting.Object)args[1];
                var keys = p.Keys;
                string[] objs = new string[keys.Length];
                for (int i=0; i < keys.Length; i++) {
                    objs[i] = p[keys[i]].ToString();
                }
                return DatabaseService.Push(path, keys, objs, keys.Length);
            }
            else {
                debug_log("Push: Unimplemented Javascript type");
                throw new Exception("Push: Unimplemented Javascript type");
            }
            return null;
        }

        object Save(Fuse.Scripting.Context context, object[] args)
        {
            var path = args[0].ToString();
            if (args[1] is Fuse.Scripting.Object) {
                var p = (Fuse.Scripting.Object)args[1];
                var keys = p.Keys;
                string[] objs = new string[keys.Length];
                for (int i=0; i < keys.Length; i++) {
                    objs[i] = p[keys[i]].ToString();
                }
                DatabaseService.Save(path, keys, objs, keys.Length);
                return null;
            }
            else {
                debug_log("Save: Unimplemented Javascript type");
                throw new Exception("Save: Unimplemented Javascript type");
            }
            return null;
        }


        void ListenCallback (string path, string msg)
        {
        	Emit("data", path, msg);
        }

		object Listen(Fuse.Scripting.Context context, object[] args)
		{
			debug_log "listen";
            var path = args[0].ToString();
			DatabaseService.Listen(path, ListenCallback);
			return null;
		}


        static object LogIt(Context context, object[] args)
        {
            var message = (string)args[0];
            // AnalyticsService.LogIt(message);
            return null;
        }
	}
}
