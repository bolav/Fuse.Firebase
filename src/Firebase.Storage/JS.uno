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

namespace Firebase.Storage.JS
{
	/**
	*/
	[UXGlobalModule]
	public sealed class StorageModule : NativeModule
	{
		static readonly StorageModule _instance;

		public StorageModule()
		{
			if(_instance != null) return;
			Resource.SetGlobalKey(_instance = this, "Firebase/Storage");

			Firebase.Storage.StorageService.Init();

            AddMember(new NativePromise<string, string>("upload", Upload, null));
            AddMember(new NativePromise<string, string>("getUrl", GetUrl, null));
		}

        static Future<string> Upload(object[] args)
        {
            var storagepath = args[0].ToString();
            var filepath = args[1].ToString();
            return new Upload(storagepath, filepath);
        }

        static Future<string> GetUrl(object[] args)
        {
            var storagepath = args[0].ToString();
            return new GetUrl(storagepath);
        }

	}

}
