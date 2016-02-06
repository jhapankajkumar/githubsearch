//
//  Constants.h
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define PER_PAGE_COUNT   20
#define OOPS_ERROR    @"Oops! Something went wrong. Please Retry"
#define APPLICATION_NAME  @"FindMyRepository"
#define OK_MESSAGE @"OK"
#define DATA_LIMIT 3

typedef enum sort
{
    SortTypeStars,
    SortTypeForks
} SortType;

typedef enum order
{
    OrderByASC,
    OrderByDESC
} OrderBy;


#endif /* Constants_h */
