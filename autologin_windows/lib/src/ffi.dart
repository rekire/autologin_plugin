import 'dart:ffi';

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:ffi/ffi.dart';

// Documentation from https://learn.microsoft.com/windows/win32/api/wincred/ns-wincred-credentialw
/// The [WinapiCredential] structure contains an individual credential.
final class WinapiCredential extends Struct {
  /// A bit member that identifies characteristics of the credential. Undefined
  /// bits should be initialized as zero and not otherwise altered to permit
  /// future enhancement.
  @Uint32()
  external int flags;

  /// The type of the credential. This member cannot be changed after the
  /// credential is created. The following values are valid.
  @Int32()
  external int type;

  /// The name of the credential. The [targetName] and [type] members uniquely
  /// identify the credential. This member cannot be changed after the
  /// credential is created. Instead, the credential with the old name should be
  /// deleted and the credential with the new name created.
  external Pointer<Utf16> targetName;

  /// A string comment from the user that describes this credential. This member
  /// cannot be longer than CRED_MAX_STRING_LENGTH (256) characters.
  external Pointer<Utf16> comment;

  /// The time, in Coordinated Universal Time (Greenwich Mean Time), of the last
  /// modification of the credential. For write operations, the value of this
  /// member is ignored.
  @Int64()
  external int lastWritten;

  /// The size, in bytes, of the [credentialBlob] member. This member cannot be
  /// larger than CRED_MAX_CREDENTIAL_BLOB_SIZE (5*512) bytes.
  @Int32()
  external int credentialBlobSize;

  /// Secret data for the credential. The [credentialBlob] member can be both
  /// read and written.
  external Pointer<Uint8> credentialBlob;

  /// Defines the persistence of this credential. This member can be read and
  /// written.
  @Uint32()
  external int persist;

  /// The number of application-defined attributes to be associated with the
  /// credential. This member can be read and written. Its value cannot be
  /// greater than CRED_MAX_ATTRIBUTES (64).
  @Uint32()
  external int attributeCount;

  /// Application-defined attributes that are associated with the credential.
  /// This member can be read and written.
  external Pointer<Pointer<CredentialAttribute>> attributes;

  /// Alias for the [targetName] member. This member can be read and written.
  /// It cannot be longer than CRED_MAX_STRING_LENGTH (256) characters.
  external Pointer<Utf16> targetAlias;

  /// The user name of the account used to connect to [targetName].
  external Pointer<Utf16> userName;
}

/// The credential is a generic credential. The credential will not be used by
/// any particular authentication package. The credential will be stored
/// securely but has no other significant characteristics.
const typeGeneric = 1;

/// The credential persists for all subsequent logon sessions on this same
/// computer. It is visible to other logon sessions of this same user on this
/// same computer and to logon sessions for this user on other computers.
//
// This option can be implemented as locally persisted credential if the
// administrator or user configures the user account to not have roam-able
// state. For instance, if the user has no roaming profile, the credential will
// only persist locally.
//
// **Windows Vista Home Basic, Windows Vista Home Premium, Windows Vista Starter
// and Windows XP Home Edition**:  This value is not supported.
const persistEnterprise = 3;

// Documentation from https://learn.microsoft.com/en-us/windows/win32/api/wincred/ns-wincred-credential_attributew
/// The [CredentialAttribute] structure contains an application-defined
/// attribute of the credential. An attribute is a keyword-value pair. It is up
/// to the application to define the meaning of the attribute.
final class CredentialAttribute extends Struct {
  /// Name of the application-specific attribute. Names should be of the form
  /// <CompanyName>_<Name>.
  //
  // This member cannot be longer than CRED_MAX_STRING_LENGTH (256) characters.
  external Pointer<Utf16> keyword;

  /// Identifies characteristics of the credential attribute. This member is
  /// reserved and should be originally initialized as zero and not otherwise
  /// altered to permit future enhancement.
  @Uint32()
  external int flags;

  /// Length of [value] in bytes. This member cannot be larger than
  /// CRED_MAX_VALUE_SIZE (256).
  @Uint32()
  external int valueSize;

  /// Data associated with the attribute. By convention, if [value] is a text
  /// string, then [value] should not include the trailing zero character and
  /// should be in UNICODE.
  //
  // Credentials are expected to be portable. The application should take care
  // to ensure that the data in value is portable. It is the responsibility of
  // the application to define the byte-endian and alignment of the data in
  // [value].
  external Pointer<Uint8> value;
}

/// The [CredWriteNative] function creates a new credential or modifies an
/// existing credential in the user's credential set. The new credential is
/// associated with the logon session of the current token. The token must
/// not have the user's security identifier (SID) disabled.
typedef CredWriteNative = Int32 Function(
  Pointer<WinapiCredential> credential,
  Uint32 flags,
);

/// The [CredWriteDart] function creates a new credential or modifies an
/// existing credential in the user's credential set. The new credential is
/// associated with the logon session of the current token. The token must not
/// have the user's security identifier (SID) disabled.
typedef CredWriteDart = int Function(
  Pointer<WinapiCredential> credential,
  int flags,
);

/// The [CredReadNative] function reads a credential from the user's credential
/// set. The credential set used is the one associated with the logon session of
/// the current token. The token must not have the user's SID disabled.
typedef CredReadNative = Int32 Function(
  Pointer<Utf16> targetName,
  Uint32 type,
  Uint32 reservedFlag,
  Pointer<Pointer<WinapiCredential>> credential,
);

/// The [CredReadDart] function reads a credential from the user's credential
/// set. The credential set used is the one associated with the logon session of
/// the current token. The token must not have the user's SID disabled.
typedef CredReadDart = int Function(
  Pointer<Utf16> targetName,
  int type,
  int reservedFlag,
  Pointer<Pointer<WinapiCredential>> credential,
);

/// The [CredFreeNative] function frees a buffer returned by any of the
/// credentials management functions.
typedef CredFreeNative = Void Function(Pointer<WinapiCredential> credential);

/// The [CredFreeDart] function frees a buffer returned by any of the
/// credentials management functions.
typedef CredFreeDart = void Function(Pointer<WinapiCredential> credential);

// Based on the win api documentation
/// The [credWrite] function creates a new credential for a [appName] with its
/// [username] and [password] or modifies an existing credential in the user's
/// credential set. The new credential is associated with the logon session of
/// the current token. The token must not have the user's security identifier
/// (SID) disabled.
bool credWrite(String username, String password, String appName) {
  final credential = calloc<WinapiCredential>();
  credential.ref.type = typeGeneric;
  credential.ref.targetName = appName.toNativeUtf16();
  credential.ref.userName = username.toNativeUtf16();
  credential.ref.credentialBlobSize = password.length * 2; // Length in bytes
  credential.ref.credentialBlob = password.toNativeUtf16().cast();
  credential.ref.persist = persistEnterprise;

  final credWrite = DynamicLibrary.open('Advapi32.dll')
      .lookupFunction<CredWriteNative, CredWriteDart>('CredWriteW');
  final resultWrite = credWrite(credential, 0);

  calloc
    ..free(credential.ref.credentialBlob)
    ..free(credential);

  return resultWrite != 0;
}

/// The CredRead function reads a credential from the user's credential set.
/// The credential set used is the one associated with the logon session of the
/// current token. The token must not have the user's SID disabled.
Credential? credRead(String appName) {
  // ignore: omit_local_variable_types
  final Pointer<Pointer<WinapiCredential>> retrievedCredential = calloc();
  final credRead = DynamicLibrary.open('Advapi32.dll')
      .lookupFunction<CredReadNative, CredReadDart>('CredReadW');
  final resultRead =
      credRead(appName.toNativeUtf16(), 1, 0, retrievedCredential);
  if (resultRead != 0) {
    final username = retrievedCredential.value.ref.userName.toDartString();
    final password =
        retrievedCredential.value.ref.credentialBlob.cast<Utf16>().toDartString(
              length: retrievedCredential.value.ref.credentialBlobSize ~/ 2,
            );
    calloc.free(retrievedCredential.value);
    return Credential(username: username, password: password);
  } else {
    calloc.free(retrievedCredential.value);
    return null;
  }
}
