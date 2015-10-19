//
//  Copyright 2012 Christoph Jerolimov
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License
//

#import "NSData+NSHash.h"
#import <CommonCrypto/CommonDigest.h>
#import "shareDefine.h"
#import <Foundation/NSFileHandle.h>

@implementation NSData (NSHash_AdditionalHashingAlgorithms)

+ (NSData *) dataWithContentsOfFile:(NSString *)path atOffset:(off_t)offset withSize:(size_t)bytes
{
    FILE *file = fopen([path UTF8String], "rb");
    if(file == NULL)
        return nil;
    
    void *data = malloc(bytes);  // check for NULL!
    fseeko(file, offset, SEEK_SET);
    fread(data, 1, bytes, file);  // check return value, in case read was short!
    fclose(file);
    
    // NSData takes ownership and will call free(data) when it's released
    return [NSData dataWithBytesNoCopy:data length:bytes];
}

+ (NSData *) dataWithContentsOfFile:(NSString *)path withSize:(size_t)size
{

    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    long long fileLength = (long long)[fileHandle seekToEndOfFile];
    [fileHandle seekToFileOffset:fileLength/2];
    NSData *chunkDataEnd = [fileHandle readDataOfLength:size];
    
    [fileHandle closeFile];

    return chunkDataEnd;
}


- (NSData*) MD5 {
	unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
	unsigned char output[outputLength];
    
    if (self.length==0) {
        return nil;
    }
    else
    {
        CC_MD5(self.bytes, (unsigned int) self.length, output);
        return [NSMutableData dataWithBytes:output length:outputLength];
    }
}

- (NSString*) MD5string {
	unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
	unsigned char output[outputLength];
    
    if (self.length==0) {
        return nil;
    }
    else
    {
    	CC_MD5(self.bytes, (unsigned int) self.length, output);
        return [self toHexString:output length:outputLength];;
    }
}

- (NSString*) BEMD5 {
	unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
    if (self.length<K_BEID_MD5_DIGEST_LENGTH) {
        return nil;
    }
    else
    {
    	CC_MD5(self.bytes, K_BEID_MD5_DIGEST_LENGTH, output);
        return [self toHexString:output length:outputLength];;
    }
}

- (NSData*) SHA1 {
	unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
    if (self.length==0) {
        return nil;
    }
    else
    {
        CC_SHA1(self.bytes, (unsigned int) self.length, output);
        return [NSMutableData dataWithBytes:output length:outputLength];
    }
}

- (NSData*) SHA256 {
	unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
	unsigned char output[outputLength];

    if (self.length==0) {
        return nil;
    }
    else
    {
        CC_SHA256(self.bytes, (unsigned int) self.length, output);
        return [NSMutableData dataWithBytes:output length:outputLength];
    }
}

- (NSString*) toHexString:(unsigned char*) data length: (unsigned int) length {

    if (data==nil) {
        return nil;
    }
    
	NSMutableString* hash = [NSMutableString stringWithCapacity:length * 2];
	for (unsigned int i = 0; i < length; i++) {
		[hash appendFormat:@"%02x", data[i]];
		data[i] = 0;
	}
	return hash;
}

@end
