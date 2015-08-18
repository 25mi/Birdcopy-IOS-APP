#import "MuWord.h"

@implementation MuWord
{
	NSMutableString *string;
	CGRect rect;
}

@synthesize string, rect;

- (id) init
{
	self = [super init];
	if (self)
	{
		self.string = [NSMutableString string];
		self.rect = CGRectNull;
	}
	return self;
}

- (void) dealloc
{
	self.string = nil;
	[super dealloc];
}

+ (MuWord *) word
{
	return [[[MuWord alloc] init] autorelease];
}

- (void) appendChar:(unichar)c withRect:(CGRect)_rect
{
	[string appendFormat:@"%C", c];
	rect = CGRectUnion(rect, _rect);
}

+ (void) selectFrom:(CGPoint)pt1 to:(CGPoint)pt2 fromWords:(NSArray *)words onStartLine:(void (^)(void))startBlock onWord:(void (^)(MuWord *))wordBlock onEndLine:(void (^)(void))endBLock
{
	CGPoint toppt, botpt;

	if (pt1.y < pt2.y)
	{
		toppt = pt1;
		botpt = pt2;
	}
	else
	{
		toppt = pt2;
		botpt = pt1;
	}

	for (NSArray *line in words)
	{
		MuWord *fst = [line objectAtIndex:0];
		float ltop = fst.rect.origin.y;
		float lbot = ltop + fst.rect.size.height;

		if (toppt.y < lbot && ltop < botpt.y)
		{
			BOOL topline = toppt.y > ltop;
			BOOL botline = botpt.y < lbot;
			float left = -INFINITY;
			float right = INFINITY;

			if (topline && botline)
			{
				left = MIN(toppt.x, botpt.x);
				right = MAX(toppt.x, botpt.x);
			}
			else if (topline)
			{
				left = toppt.x;
			}
			else if (botline)
			{
				right = botpt.x;
			}

			startBlock();

			for (MuWord *word in line)
			{
				float wleft = word.rect.origin.x;
				float wright = wleft + word.rect.size.width;

				if (wright > left && wleft < right)
					wordBlock(word);
			}

			endBLock();
		}
	}
}

+ (void) selectfromWords:(NSArray *)words onStartLine:(void (^)(void))startBlock onWord:(void (^)(MuWord *))wordBlock onEndLine:(void (^)(void))endBLock
{
    for (NSArray *line in words)
	{
		startBlock();
            
		for (MuWord *word in line)
		{
           wordBlock(word);
		}
            
        endBLock();
	}
}


+ (NSString *) allText:(NSArray *)words
{
	__block NSMutableString *text = [NSMutableString string];
	__block NSMutableString *line;
    
	[MuWord selectfromWords:words
           onStartLine:^{
               line = [NSMutableString string];
           } onWord:^(MuWord *w) {
               if (line.length > 0)
                   [line appendString:@" "];
               [line appendString:w.string];
           } onEndLine:^{
               if (text.length > 0)
                   [text appendString:@"\n"];
               [text appendString:line];
           }];
    
	return text;
}

+  (NSArray *) allRects:(NSArray *)words
{
	NSMutableArray *arr = [NSMutableArray array];
	__block CGRect r;
    
	[MuWord selectfromWords:words
           onStartLine:^{
               r = CGRectNull;
           } onWord:^(MuWord *w) {
               r = CGRectUnion(r, w.rect);
           } onEndLine:^{
               if (!CGRectIsNull(r))
                   [arr addObject:[NSValue valueWithCGRect:r]];
           }];
    
	return arr;
}

@end
