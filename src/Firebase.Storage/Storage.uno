using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Triggers;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Controls.Native.Android;
using Uno.Threading;

namespace Firebase.Storage
{
    [Require("Cocoapods.Podfile.Target", "pod 'Firebase/Storage'")]
    [extern(iOS) Require("Source.Import","FirebaseStorage/FirebaseStorage.h")]
    extern(mobile)
    static class StorageService
    {
        static bool _initialized;
        extern(android) static Java.Object _handle;
        extern(ios) public static ObjC.Object _handle;

        public static void Init()
        {
            if (!_initialized)
            {
                Firebase.Core.Init();
                if defined(android) AndroidInit();
                if defined(ios) iOSInit();
                _initialized = true;
            }
        }

        [Foreign(Language.ObjC)]
        extern(iOS)
        public static void iOSInit()
        @{
            // Get a reference to the storage service using the default Firebase App
            FIRStorage *storage = [FIRStorage storage];

            // Create a storage reference from our storage service
            FIRStorageReference *storageRef = [storage referenceForURL:@"@(Project.Firebase.Storage)"];

        	@{_handle:Set(storageRef)};
        @}


        [Foreign(Language.Java)]
        extern(android)
        public static void AndroidInit()
        @{
            @{_handle:Set(FirebaseDatabase.getInstance().getReference())};
        @}
	}

    extern(!mobile)
    static class StorageService
    {
        public static void Init() {}
    }

    extern(!mobile)
    internal class Upload : Promise<string>
    {
        public Upload(string storagepath, string filepath)
        {
            Reject(new Exception("Not implemented on desktop"));
        }
    }

    [Require("Entity", "StorageService")]
    [extern(iOS) Require("Source.Import","FirebaseStorage/FirebaseStorage.h")]
    [Require("Source.Include","@{StorageService:Include}")]
    extern(iOS)
    internal class Upload : Promise<string>
    {
    	[Foreign(Language.ObjC)]
    	public Upload(string storagepath, string filepath)
    	@{
    		FIRStorageReference *ref = @{StorageService._handle:Get()};
            NSURL *localFile = [NSURL URLWithString:filepath];

            FIRStorageUploadTask *uploadTask = [[ref child:storagepath] putFile:localFile metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
              if (error != nil) {
                NSString *erstr = [NSString stringWithFormat:@"Firebase Storage Upload Error: %@", error.localizedDescription];
                @{Upload:Of(_this).Reject(string):Call(erstr)};
              } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                NSURL *downloadURL = metadata.downloadURL;
                @{Upload:Of(_this).Resolve(string):Call([downloadURL absoluteString])};
              }
            }];
    	@}
    	void Reject(string reason) { Reject(new Exception(reason)); }
    }

    extern(!mobile)
    internal class GetUrl : Promise<string>
    {
        public GetUrl(string storagepath)
        {
            Reject(new Exception("Not implemented on desktop"));
        }
    }

    [Require("Entity", "StorageService")]
    [extern(iOS) Require("Source.Import","FirebaseStorage/FirebaseStorage.h")]
    [Require("Source.Include","@{StorageService:Include}")]
    extern(iOS)
    internal class GetUrl : Promise<string>
    {
        [Foreign(Language.ObjC)]
        public GetUrl(string storagepath)
        @{
            FIRStorageReference *ref = @{StorageService._handle:Get()};

            [[ref child:storagepath] downloadURLWithCompletion:^(NSURL *URL, NSError *error){
              if (error != nil) {
                NSString *erstr = [NSString stringWithFormat:@"Firebase Storage URL Error: %@", error.localizedDescription];
                @{GetUrl:Of(_this).Reject(string):Call(erstr)};
              } else {
                @{GetUrl:Of(_this).Resolve(string):Call([URL absoluteString])};
              }
            }];
        @}
        void Reject(string reason) { Reject(new Exception(reason)); }
    }



    [ForeignInclude(Language.Java,
        "com.google.firebase.database.DatabaseReference",
        "com.google.firebase.database.DatabaseError",
        "com.google.firebase.database.DatabaseReference",
        "com.google.firebase.database.DataSnapshot",
        "com.google.firebase.database.ValueEventListener",
        "org.json.JSONObject",
        "java.util.Map")]
    extern(Android)
    internal class Read : Promise<string>
    {
        [Foreign(Language.Java)]
        public Read(string path)
        @{
            ValueEventListener dataListener = new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    JSONObject json = new JSONObject((Map)dataSnapshot.getValue());
                    @{Read:Of(_this).Resolve(string):Call(json.toString())};
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    @{Read:Of(_this).Reject(string):Call(databaseError.toString())};
                }
            };
            DatabaseReference ref = (DatabaseReference)@{DatabaseService._handle:Get()};
            ref.child(path).addListenerForSingleValueEvent(dataListener);
        @}
        void Reject(string reason) { Reject(new Exception(reason)); }
    }
}
