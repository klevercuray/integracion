CREATE OR REPLACE PACKAGE BANINST1.gb_advq_util AS
--AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : GOKB_ADVQ_UTIL0
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Fri Dec 04 09:17:28 2009
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
/**
* Oracle AQ utility package that wraps the dbms_aqadm functionality and adds convenience procedures/functions
* related to AQ.
*
*/

-- FILE NAME..: gokb_advq_util0.sql
-- RELEASE....: 8.3
-- OBJECT NAME: gb_advq_util
-- PRODUCT....: GENERAL
-- USAGE......: Package support, the Banner Event API for publishing to AQ any
--              entity changes, and an AQ alternative communication to that of
--              the DBMS_PIPE.
-- COPYRIGHT..: Copyright 2004 - 2009 SunGard. All rights reserved.
--
-- DESCRIPTION:
--
-- Publishes messages to oracle AQ multi consumer queue(s) and provides AQ
-- administration and reporting utilities.
-- Also supports an AQ alternative communication mechanism to that of
-- DBMS_PIPE. Pipe comminication is between sessions in the same instance
-- and therefore not ideal in a RAC configuration. This AQ alternative
-- communication mechanism supports publishing and consuming to single
-- consumer queue(s) with a specific payload datatype of g_msg_fragments.
--
-- DESCRIPTION END
--
-- Procedures:
--  p_enqueue_MESSAGE
--    Enqueues an xml message to AQ multi consumer queue.
--  P_CREATE_QUEUE
--    Creates AQ Queue
--  P_ADD_SUBSCRIBER
--    Adds subscriber to AQ queue
--  P_DROP_QUEUE
--    Drops AQ Queue and the underlying QueueTable. Dropping the QueueTable will purge
--    all the messages in the QueueTable.
--  P_DROp_queue_table
--    Drops AQ Queue table
--  P_DISPLAY_SUBSCRIBERS
--    Displays all subscribers configured for an AQ Queue
--  P_DISPLAY_MESSAGES
--    Displays messages in an AQ Queue along with their status(PROCESSED/READY..etc)
--  P_REMOVE_SUBSCRIBER
--      Drops subscriber associated to an AQ Queue
--  PROCEDURE P_RESTART_QUEUE
--      Restarts AQ Queue
--  P_PURGE_MESSAGES
--    Purge messages in a queue for a subscriber
-- -- -- --
-- -- -- --
--  P_ENQUEUE_MSG_FRAGMENTS
--    Enqueues a g_msg_fragments message to AQ single consumer queue
--  P_DEQUEUE_MSG_FRAGMENTS
--    Dequeues a g_msg_fragments message from AQ single consumer queue
--  P_DEQUEUE_MSG_FRAGMENTS_CONDIT
--    Dequeues a g_msg_fragments message conditionally from AQ single
--    consumer queue
--  P_PURGE_ENTIRE_QUEUE
--    Purge messages in a single consumer queue
--  P_HANDSHAKE_MSG_FRAGMENTS_ENQ
--    Handle the passoff of g_msg_fragments from Oracle*Form to enqueue
--    procedure for AQ single consumer queue
--  P_HANDSHAKE_MSG_FRAGMENTS_DEQ1
--    Handle the passoff of g_msg_fragments from conditional dequeue
--    procedure for AQ single consumer queue into Oracle*Form.
--    This is specific to GURJOBS_RTN_Q handshake
-- -- -- --
-- -- -- --
-- Functions:
--  F_GET_MF_MISC_01_VALUE
--    Returns value of the mf_misc_01 fragment from g_msg_fragments object
--  F_QUEUE_EXISTS
--    Checks if a Queue exists in AQ
--  F_QUEUE_TABLE_EXISTS
--    Checks if a Queue table exists in AQ
--  F_GET_MESSAGE_COUNT
--    Gets number of messages in AQ Queue
-- -- -- --
-- -- -- --
--  F_USE_AQ_AND_NOT_PIPES
--    Based upon GTVSDAX value returns Y or N. Y indicates to use this AQ
--    alternative communication mechanism. N indicates to continue to use
--    DBMS_PIPE
--  F_DBA_QUEUE_TABLE_EXISTS
--    Returns True if the passed Queue Table has been established.
--  F_QUEUE_ENABLED_FOR_PURGE
--    Returns True if the passed Queue Name is available for dequeing.
--  F_COUNT_QTABLE_ROWS
--    Returns number of g_msg_fragments message in a QTAB
--  F_GET_UNIQUE_TOKEN RETURN VARCHAR2;
--    Returns a unique identification for use with conditional dequeunig
-- -- -- --
-- -- -- --
--
/**
* Enqueues an xml message.
* @param p_xml Business entity data to be enqueued
* @param p_bulk_synchronization Indicates if entities are being synchronized in bulk
* @param p_bulk_sync_code Bulk Synchronization code that is the target system name
* @param p_entity_list Unique list of busines entities that are contained in the xml
* @param p_vpd_inst_code VPD Institution code
* @param p_sync_publisher_enabled Indicator determining if entities need to be sync'd/published by the gateway
*/
  PROCEDURE p_enqueue_message(p_xml                    CLOB,
                              p_bulk_synchronization   BOOLEAN,
                              p_bulk_sync_code         VARCHAR2,
                              p_entity_list            string_nt,
                              p_vpd_inst_code          VARCHAR2,
                              p_sync_publisher_enabled BOOLEAN,
                              p_message_id             NUMBER);
--
/**
* Creates AQ queue/topic.
* @param p_queue_table Name of table that holds the Queue/Topic data
* @param p_queue_table Payload that the Queue/Topic holds
* @param p_queue_name Queue Name
* @param p_queue_type Queue type (Noraml/Exception)
* @param p_multiple_consumers Indicator to differentiate between a Queue/Topic
*/
  PROCEDURE p_create_queue(p_queue_table        IN VARCHAR2,
                           p_PAYLOAD_TYPE 		IN VARCHAR2,
                           p_queue_name         IN VARCHAR2,
                           p_queue_type         IN INTEGER := dbms_aqadm.normal_queue,
                           p_multiple_consumers IN BOOLEAN);
--
/**
* Adds a subscriber to a Destination(Queue/Topic).
* @param p_queue_name Queue to which a subscriber is being added
* @param p_subscriber_name Name of Subscriber being added
*/
  PROCEDURE p_add_subscriber(p_queue_name      IN VARCHAR2,
                             p_subscriber_name IN VARCHAR2);
--
/**
* Remove a subscriber associated with a Queue/Topic.
* @param p_queue_name Queue/Topic whose subscriber is being removed
* @param p_subscriber_name Name of subscriber being removed.
*/
  PROCEDURE p_remove_subscriber(p_queue_name      IN VARCHAR2,
                                p_subscriber_name IN VARCHAR2);
--
/**
* Restarts a Queue/Topic.
* @param p_queue_name Queue/Topic to restart
* @param p_wait Indicator to determine whether to wait for any outstanding transactions to complete.
*/
  PROCEDURE p_restart_queue(p_queue_name IN VARCHAR2,
                            p_wait       IN BOOLEAN := TRUE);
--
/**
* Drops a Queue/Topic and the underlying Queue table. Dropping the Queue table will delete
* all messages from the Queue table.
* @param p_queue_table Queue table that holds the Queue/Topic data
* @param p_queue_name Queue/Topic name
* @param p_enqueue Indicator to disable Queueing on this queue
* @param p_dequeue Indicator to disable DeQueueing on this queue
* @param p_wait Indicator to determine whether to wait for any outstanding transactions to complete
*/
  PROCEDURE p_drop_queue(p_queue_table IN VARCHAR2,
                         p_queue_name  IN VARCHAR2 := '%',
                         p_enqueue     IN BOOLEAN := TRUE,
                         p_dequeue     IN BOOLEAN := TRUE,
                         p_wait        IN BOOLEAN := TRUE);
--
/**
* Drop the queue table and force all queues to be stopped and dropped
* by the system. This will delete all the messages from the queue table.
* @param p_queue_table Queue/Topic table that holds the Queue/Topic data
* @param p_force Controls dropping of Queue table.
* {*} FALSE Drop action will not succeed unless all queues associated
* with this Queue table are dropped
* {*} TRUE Force drop this queue table. Remaining queues will be automatically
* stopped and dropped.
* @param p_auto_commit Commit control.
* {*} FALSE Commits the current transaction before the operation is carried
* out. Operation becomes persistent when the call returns.
* {*} TRUE Force Drop action becomes part of the current transaction thereby
* taking affect only when calling session issues a commit.
*/
  PROCEDURE p_drop_queue_table(p_queue_table IN VARCHAR2,
                               p_force       IN BOOLEAN := FALSE,
                               p_auto_commit IN BOOLEAN := TRUE);
--
/**
* Displays subscribers associated with a Destination (Queue/Topic).
* @param p_queue_name Name of Queue
*/
  PROCEDURE p_display_subscribers(p_queue_name IN VARCHAR2);
--
/**
* Purge messages associated to a Destination (Queue/Topic) for a subscriber.
* @param p_queue_name Name of Queue
* @param p_subscriber Name of Subscriber
*/
  PROCEDURE p_purge_messages(p_queue VARCHAR2, p_subscriber VARCHAR2);
--
/**
* Display message header info for a particular queue.
* @param p_queue_table Queue table name
* @param p_queue_name Name of Queue
*/
  PROCEDURE p_display_messages(p_queue_table IN VARCHAR2,
                               p_queue_name  IN VARCHAR2);
-- -- -- --
-- -- -- --
/**
* Enqueues a g_msg_fragments message to AQ single consumer queue.
* @param p_queue_name Name of the Queue
* @param p_msg_fragments contains the payload of message fragments to enqueue
* @param p_delivery_mode indicates a PERSISTENT or BUFFERED message. Persistent is default.
*/
  PROCEDURE p_enqueue_msg_fragments(
                                    p_queue_name    IN VARCHAR2,
                                    p_msg_fragments IN g_msg_fragments,
                                    p_delivery_mode IN NUMBER := 1);
--
/**
* Dequeues a g_msg_fragments message from AQ single consumer queue.
* @param p_queue_name Name of the Queue
* @param p_max_wait if not null, contains number in seconds to listen for a message to dequeue
* @param p_msg_fragments contains the payload of message fragments dequeued
* @param p_remove_nodata default is 'N', if 'Y' will set dequeue_mode to remove without need for payload
*/
  PROCEDURE p_dequeue_msg_fragments(
                                    p_queue_name    IN VARCHAR2,
                                    p_max_wait      IN NUMBER,
                                    p_msg_fragments OUT g_msg_fragments,
                                    p_remove_nodata IN VARCHAR2 DEFAULT 'N');
--
/**
* Dequeues a g_msg_fragments message conditionally from AQ single consumer queue.
* @param p_queue_name Name of the Queue
* @param p_condit_value string value evaluated against g_msg_fragments.mf_misc_01 value.
* @param p_max_wait seconds (multiplied by a factor, p_wait_factor) to conditionally listen for a message to dequeue
* @param p_wait_factor with p_max_wait seconds to establish duration to conditionally listen for a message to dequeue
* @param p_msg_fragments contains the payload of message fragments dequeued
*/
  PROCEDURE p_dequeue_msg_fragments_condit(
                                    p_queue_name    IN VARCHAR2,
                                    p_condit_value  IN VARCHAR2,
                                    p_max_wait      IN NUMBER,
                                    p_wait_factor   IN NUMBER,
                                    p_msg_fragments OUT g_msg_fragments);
--
/**
* Purge the g_msg_fragments messages in single consumer Queue
* @param p_queue_name Name of the Queue
* @param p_items_in_queue indicates number of messages in the Queue and how many to purge
*/
  PROCEDURE P_PURGE_ENTIRE_QUEUE(p_queue_name     IN VARCHAR2,
                                 p_items_in_queue IN NUMBER);
--
/**
* To handle the passoff of g_msg_fragments from Oracle*Form to enqueue procedure for AQ single
* consumer queue
* @param p_queue_name Name of the Queue
* @param p_return_status Status of the execution of this procedure. A '0' indicates success.
* @param p_mf_misc_01 miscellanous message fragment
* @param p_mf_01 message fragment 01
* @param p_mf_02 message fragment 02
* @param p_mf_03 message fragment 03
* @param p_mf_04 message fragment 04
* @param p_mf_05 message fragment 05
* @param p_mf_06 message fragment 06
* @param p_mf_07 message fragment 07
* @param p_mf_08 message fragment 08
* @param p_mf_09 message fragment 09
* @param p_mf_10 message fragment 10
*/
 PROCEDURE P_HANDSHAKE_MSG_FRAGMENTS_ENQ(
                           p_queue_name    IN VARCHAR2,
                           p_return_status OUT VARCHAR2,
                           p_mf_misc_01    IN VARCHAR2,
                           p_mf_01         IN SYS.ANYDATA,
                           p_mf_02         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_03         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_04         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_05         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_06         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_07         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_08         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_09         IN SYS.ANYDATA DEFAULT NULL,
                           p_mf_10         IN SYS.ANYDATA DEFAULT NULL);

--
/**
* Handle the passoff of g_msg_fragments from conditional dequeue procedure for AQ single consumer queue
* into Oracle*Form. This is specific to GURJOBS_RTN_Q handshake
* @param p_queue_name Name of the Queue
* @param p_condit condition value that is compared to mf_misc_01 for dequeue
* @param p_max_wait seconds (multiplied by a factor, p_wait_factor) to conditionally listen for a message to dequeue
* @param p_wait_factor with p_max_wait seconds to establish duration to conditionally listen for a message to dequeue
* @param p_return_status Status of the execution of this procedure. A '0' indicates success.
* @param p_response for gurjobs_rtn_q this is from p_mf_misc_01 message fragment
*/
 PROCEDURE P_HANDSHAKE_MSG_FRAGMENTS_DEQ1(
                          p_queue_name     IN VARCHAR2,
                          p_condit         IN VARCHAR2,
                          p_max_wait       IN NUMBER,
                          p_wait_factor    IN NUMBER,
                          p_return_status  OUT VARCHAR2,
                          p_response       OUT VARCHAR2);

-- -- -- --
-- -- -- --
/**
* Returns the mf_misc_01 value of type VARCHAR2 during conditional dequeue
* @param p_msg_fragments item from the Queue user_data, payload
*/
  FUNCTION f_get_mf_misc_01_value(p_msg_fragments IN g_msg_fragments)
           RETURN VARCHAR2;
--
/**
* Checks whether a Destination (Queue/Topic) exists.
* @param p_queue_name Name of Queue
*/
  FUNCTION f_queue_exists(p_queue_name IN VARCHAR2) RETURN BOOLEAN;
--
/**
* Checks whether a Queue/Topic table exists.
* @param p_queue_table Name of Queue
*/
  FUNCTION f_queue_table_exists(p_queue_table IN VARCHAR2) RETURN BOOLEAN;
--
/**
* Returns True if the passed Queue Name is available for dequeuing
* @param p_queue_name Name of Queue
*/
  FUNCTION f_queue_enabled_for_purge(p_queue_name IN VARCHAR2) RETURN BOOLEAN;
--
/**
* Returns the number of messages for a particular destination.
* @param p_queue_table Name of Queue table that holds data for a Destination (Queue/Topic)
* @param p_queue_name Name of Queue
*/
  FUNCTION f_get_message_count(p_queue_table IN VARCHAR2,
                               p_queue_name  IN VARCHAR2) RETURN INTEGER;
--
-- --
-- --
/**
* Based on GTVSDAX returns Y or N. Y indicates to use AQ alternative
* communication mechanism. N indicates to continue to use DBMS_PIPE. N is
* returned if the row is not found.  If database 11g (or higher) is being
* used, function will pull the return value from the result cache
* @param p_code value for GTVSDAX code lookup (AQ4PIPES)
* @param p_group_code value for GTVSDAX group code (GURJOBS,SSO,GOKOUTD,GOKOUTP)
*/
  FUNCTION F_USE_AQ_AND_NOT_PIPES(p_code IN VARCHAR2,
                                  p_group_code IN VARCHAR2) RETURN BOOLEAN
  $IF DBMS_DB_VERSION.VERSION >= 11
  $THEN
      RESULT_CACHE
  $END
;
--
/**
* Returns True if the passed Queue Table has been established
* @param p_queue_table Name of the Queue Table
*/
  FUNCTION F_DBA_QUEUE_TABLE_EXISTS(p_queue_table IN VARCHAR2) RETURN BOOLEAN;
--
/**
* Returns number of g_msg_fragments message for a given Queue Table
* @param p_queue_table Name of the Queue Table
* @param p_query_str constructed query string. established for debug need.
*/
  FUNCTION F_COUNT_QTABLE_ROWS(p_queue_table IN VARCHAR2,
                               p_query_str   OUT VARCHAR2) RETURN NUMBER;
--
/**
* Returns a unique identification for use with conditional dequeunig
*/
  FUNCTION F_GET_UNIQUE_TOKEN RETURN VARCHAR2;
-- --
-- --
END gb_advq_util;
/
CREATE OR REPLACE PACKAGE BODY BANINST1.gb_advq_util AS
  --AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : GOKB_ADVQ_UTIL1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Fri May 14 11:16:38 2010
-- MSGSIGN : #24d6b980bb0a1f8e
--TMI18N.ETR DO NOT CHANGE--
--
  -- FILE NAME..: gokb_advq_util1.sql
  -- RELEASE....: 8.3.0.4
  -- OBJECT NAME: gb_advq_util
  -- PRODUCT....: GENERAL
  -- USAGE......: Package contains AQ messaging utilities
  -- COPYRIGHT..: Copyright 2004 - 2009 SunGard. All rights reserved.
  --
  -- DESCRIPTION:
  --
  -- Provides AQ messaging utility procedures.
  --
  -- DESCRIPTION END
  --

  --
  -- private package level constants
  --
  BULK_SYNC_TOPIC CONSTANT VARCHAR2(29) := 'baninst1.EVENT_BULKSYNC_TOPIC';
  SYNC_TOPIC      CONSTANT VARCHAR2(25) := 'baninst1.EVENT_SYNC_TOPIC';
  AQ_EXCEPTION_QUEUE_PREFIX CONSTANT VARCHAR2(4) := 'AQ$_';
  AQ_EXCEPTION_QUEUE_SUFFIX CONSTANT VARCHAR2(2) := '_E';
  --
  -- public functions
  --
  FUNCTION f_get_mf_misc_01_value(p_msg_fragments IN g_msg_fragments)
           RETURN VARCHAR2 IS
  BEGIN
    RETURN(p_msg_fragments.mf_misc_01);
  END f_get_mf_misc_01_value;
  -- --
  FUNCTION f_queue_exists(p_queue_name IN VARCHAR2) RETURN BOOLEAN IS
    CURSOR q_cur IS
      SELECT 'x' FROM user_queues WHERE NAME = upper(p_queue_name);
    q_rec q_cur%ROWTYPE;
  BEGIN
    OPEN q_cur;
    FETCH q_cur
      INTO q_rec;
    RETURN q_cur%FOUND;
  END f_queue_exists;
  --
  FUNCTION f_queue_table_exists(p_queue_table IN VARCHAR2) RETURN BOOLEAN IS
    CURSOR q_cur IS
      SELECT 'x'
        FROM user_queue_tables
       WHERE queue_table = upper(p_queue_table);
    q_rec q_cur%ROWTYPE;
  BEGIN
    OPEN q_cur;
    FETCH q_cur
      INTO q_rec;
    RETURN q_cur%FOUND;
  END f_queue_table_exists;
  --
  FUNCTION f_get_message_count(p_queue_table IN VARCHAR2,
                               p_queue_name  IN VARCHAR2) RETURN INTEGER IS
    retval    PLS_INTEGER;
    lv_qtable VARCHAR2(100) := 'AQ$' || p_queue_table;
    lv_sql    VARCHAR2(2000) := 'SELECT COUNT(*) FROM ' || lv_qtable ||
                                ' WHERE queue = :1';
  BEGIN
    EXECUTE IMMEDIATE lv_sql
      INTO retval
      USING p_queue_name;
    RETURN retval;
  END f_get_message_count;
  --
  -- public procedures
  --
  PROCEDURE p_create_queue(p_queue_table        IN VARCHAR2,
                           p_PAYLOAD_TYPE       IN VARCHAR2,
                           p_queue_name         IN VARCHAR2,
                           p_queue_type         IN INTEGER := dbms_aqadm.normal_queue,
                           p_multiple_consumers IN BOOLEAN) IS
  BEGIN
    IF NOT f_queue_table_exists(p_queue_table) THEN
      dbms_aqadm.create_queue_table(queue_table        => p_queue_table,
                                    queue_payload_type => p_PAYLOAD_TYPE,
                                    sort_list          => 'ENQ_TIME',
                                    multiple_consumers => p_multiple_consumers,
                                    storage_clause     => 'TABLESPACE BANAQ');
    END IF;

    IF NOT f_queue_exists(p_queue_name) THEN
      dbms_aqadm.create_queue(queue_name  => p_queue_name,
                              queue_table => p_queue_table,
                              queue_type  => p_queue_type);
    END IF;

    dbms_aqadm.start_queue(queue_name => p_queue_name,
                           enqueue    => p_queue_type !=
                                         dbms_aqadm.exception_queue);
  END p_create_queue;
  --
  PROCEDURE p_restart_queue(p_queue_name IN VARCHAR2,
                            p_wait       IN BOOLEAN := TRUE) AS
  BEGIN
    dbms_aqadm.stop_queue(queue_name => p_queue_name,
                          enqueue    => TRUE,
                          dequeue    => TRUE,
                          wait       => p_wait);
    dbms_aqadm.start_queue(queue_name => p_queue_name,
                           enqueue    => TRUE);
  END p_restart_queue;
  --
  --
  PROCEDURE p_add_subscriber(p_queue_name      IN VARCHAR2,
                             p_subscriber_name IN VARCHAR2) IS
  BEGIN
    dbms_aqadm.add_subscriber(p_queue_name,
                              sys.aq$_agent(p_subscriber_name,
                                            NULL,
                                            0));
  END p_add_subscriber;
  --
  PROCEDURE p_remove_subscriber(p_queue_name      IN VARCHAR2,
                                p_subscriber_name IN VARCHAR2) IS
  BEGIN
    dbms_aqadm.remove_subscriber(p_queue_name,
                                 sys.aq$_agent(p_subscriber_name,
                                               NULL,
                                               0));
  END p_remove_subscriber;
  --
  PROCEDURE p_drop_queue(p_queue_table IN VARCHAR2,
                         p_queue_name  IN VARCHAR2 := '%',
                         p_enqueue     IN BOOLEAN := TRUE,
                         p_dequeue     IN BOOLEAN := TRUE,
                         p_wait        IN BOOLEAN := TRUE) IS
    --select all queues associated with a queue table from user_queues
    CURSOR q_cur IS
      SELECT name
        FROM user_queues
       WHERE queue_table = upper(p_queue_table);

    all_dropped BOOLEAN := p_enqueue AND p_dequeue;
  BEGIN
    -- stop and drop all queues associated to a queue table.
    -- if an exception queue is not specified during queue creation, Oracle automatically creates
    -- the default exception queue AQ$_<queue_table>_E
    -- An exception_queue is a repository for all expired or unserviceable messages.
    FOR q_rec IN q_cur LOOP
      IF (q_rec.name LIKE upper(p_queue_name) OR
         (q_rec.name LIKE AQ_EXCEPTION_QUEUE_PREFIX ||
                          UPPER(p_queue_table) ||
                          AQ_EXCEPTION_QUEUE_SUFFIX) )
      THEN
        dbms_aqadm.stop_queue(q_rec.name,
                              p_enqueue,
                              p_dequeue,
                              p_wait);
        IF p_enqueue
           AND p_dequeue THEN
          dbms_aqadm.drop_queue(q_rec.name);
        END IF;
      ELSE
        all_dropped := FALSE;
      END IF;
    END LOOP;

    -- after all queues associated to a queue table are dropped, drop the queue table and delete ALL messages.
    IF all_dropped
       AND f_queue_table_exists(p_queue_table) THEN
      dbms_aqadm.drop_queue_table(p_queue_table);
    END IF;
  END p_drop_queue;
  --
  PROCEDURE p_drop_queue_table(p_queue_table IN VARCHAR2,
                               p_force       IN BOOLEAN := FALSE,
                               p_auto_commit IN BOOLEAN := TRUE) IS
  BEGIN
    IF (f_queue_table_exists(p_queue_table)) THEN
      dbms_aqadm.drop_queue_table(p_queue_table,
                                  p_force,
                                  p_auto_commit);
    END IF;
  END p_drop_queue_table;
  --
  PROCEDURE p_display_messages(p_queue_table IN VARCHAR2,
                               p_queue_name  IN VARCHAR2) IS
    TYPE aq_messages IS REF CURSOR;
    lv_message  aq_messages;
    v_consumer  VARCHAR2(30);
    v_msg_id    VARCHAR2(60);
    v_msg_state VARCHAR2(30);
    v_enq_time  DATE;
    lv_qtable   VARCHAR2(100) := 'AQ$' || p_queue_table;
    lv_sql      VARCHAR2(2000) := 'SELECT msg_id, consumer_name, msg_state, enq_time FROM ' ||
                                  lv_qtable || ' WHERE queue = :1';
  BEGIN
    OPEN lv_message FOR lv_sql
      USING p_queue_name;
    dbms_output.put_line('            Msg ID                          Consumer              State       Enqueue Time');
    dbms_output.put_line('------------------------------------------------------------------------------------------------');
    LOOP
      FETCH lv_message
        INTO v_msg_id, v_consumer, v_msg_state, v_enq_time;
      dbms_output.put_line(rpad(rawtohex(v_msg_id),
                                36) || rpad(v_consumer,
                                            30) ||
                           rpad(v_msg_state,
                                12) || rpad(to_char(v_enq_time,
                                                    ''||G$_DATE.GET_NLS_DATE_FORMAT||' hh24:mi:ss'),
                                            30));
      EXIT WHEN lv_message%NOTFOUND;
    END LOOP;
    CLOSE lv_message;
  END p_display_messages;
  --
  PROCEDURE p_display_subscribers(p_queue_name IN VARCHAR2) IS
    sublist dbms_aqadm.aq$_subscriber_list_t;
    v_row   PLS_INTEGER;
  BEGIN
    /* Retrieve subscriber list.*/
    sublist := dbms_aqadm.queue_subscribers(p_queue_name);
    v_row   := sublist.FIRST;
    LOOP
      EXIT WHEN v_row IS NULL;
      dbms_output.put_line(sublist(v_row).name);
      v_row := sublist.NEXT(v_row);
    END LOOP;
  END p_display_subscribers;
  --
  PROCEDURE p_purge_messages(p_queue VARCHAR2, p_subscriber VARCHAR2)
  /**
    * This procedure does not purge the messages explicitly. It marks them as dequeued( PROCESSED ).
    * If retention is set to zero, implies all PROCESSED messages will be deleted after dequeue from the queue table.
    * If multiple subscribers exist for a queue, this procedure needs to be called for all subscribers to purge messages
    * from this queue. Until all consumers consume the message (mark messages in PROCESSED state) they are NOT deleted.
    */
   IS
    no_messages EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_messages,
                          -25228);
    queueopts     dbms_aq.dequeue_options_t;
    msgprops      dbms_aq.message_properties_t;
    msgid         RAW(16);
    my_msg        sys.aq$_jms_text_message;
    message_count NUMBER := 0;
  BEGIN
    -- Queue Options when purging ( mark messages as dequeued ):
    -- do not wait for messages to arrive, if there aren't any
    -- point to the first message that meets the criteria
    -- do not retrieve payload. ( use DBMS_AQ.REMOVE to retrieve payload )
    queueopts.wait          := dbms_aq.no_wait;
    queueopts.navigation    := dbms_aq.first_message;
    queueopts.dequeue_mode  := dbms_aq.remove_nodata;
    queueopts.consumer_name := p_subscriber;
    queueopts.visibility    := dbms_aq.IMMEDIATE;
    LOOP
      BEGIN
        dbms_aq.dequeue(p_queue,
                        queueopts,
                        msgprops,
                        my_msg,
                        msgid);
        dbms_output.put_line('Dequeued message id is ' || rawtohex(msgid));
        message_count := message_count + 1;
      EXCEPTION
        WHEN no_messages THEN
          RAISE;
      END;
    END LOOP;
  EXCEPTION
    WHEN no_messages THEN
      dbms_output.put_line(to_char(message_count) ||
                           ' messages dequeued/purged');
    WHEN OTHERS THEN
      dbms_output.put_line('EXCEPTION ' || SQLCODE || ':' || SQLERRM);
  END p_purge_messages;
  --
  PROCEDURE p_publish_bulk_sync(p_xml                    CLOB,
                                p_bulk_sync_code         VARCHAR2,
                                p_entity_list            string_nt,
                                p_vpd_inst_code          VARCHAR2,
                                p_sync_publisher_enabled BOOLEAN,
                                p_message_id             NUMBER) IS
    message            sys.aq$_jms_text_message;
    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid              RAW(16);
    idx                PLS_INTEGER := p_entity_list.FIRST;
  BEGIN
    message := sys.aq$_jms_text_message.construct;
    IF (p_vpd_inst_code IS NOT NULL) THEN
      message.set_string_property('VPDINST',
                                  p_vpd_inst_code);
    END IF;
    message.set_string_property('BENTITY_BULK_SYNC_CODE',
                                p_bulk_sync_code);
    message.set_string_property('MESSAGE_ID',
                                p_message_id);
    -- set message property for all entities in the message
    LOOP
      EXIT WHEN idx IS NULL;
      message.set_string_property('BENTITY_' || p_entity_list(idx),
                                  p_entity_list(idx));
      idx := p_entity_list.NEXT(idx);
    END LOOP;
    message.set_boolean_property('SYNC_PUBLISHER_ENABLED',
                                 p_sync_publisher_enabled);
    message.set_text(p_xml);

    enqueue_options.visibility := dbms_aq.on_commit;

    dbms_aq.enqueue(queue_name         => BULK_SYNC_TOPIC,
                    enqueue_options    => enqueue_options,
                    message_properties => message_properties,
                    payload            => message,
                    msgid              => msgid);
  EXCEPTION
    WHEN OTHERS THEN
      /**
      * If topic has subscribers associated with it and if ALL consumers have message selectors that
      * evaluate to false, then the message is discarded (message not created/delivered by AQ engine) and
      * AQ raises the exception 'ORA-24033: no recipients for message'. Supress raising this exception
      * if the topic has subscribers associated with it. This implies that all the consumers have a filter
      * and that filter condition evaluates to false.
      */
      IF (NOT (SQLCODE = -24033 AND
          dbms_aqadm.queue_subscribers(BULK_SYNC_TOPIC).COUNT > 0)) THEN
        RAISE;
      END IF;
  END p_publish_bulk_sync;
  --
  PROCEDURE p_publish_sync(p_xml                    CLOB,
                           p_entity_list            string_nt,
                           p_vpd_inst_code          VARCHAR2,
                           p_sync_publisher_enabled BOOLEAN,
                           p_message_id             NUMBER) IS
    message            sys.aq$_jms_text_message;
    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid              RAW(16);
    idx                PLS_INTEGER := p_entity_list.FIRST;
  BEGIN
    message := sys.aq$_jms_text_message.construct;
    IF (p_vpd_inst_code IS NOT NULL) THEN
      message.set_string_property('VPDINST',
                                  p_vpd_inst_code);
    END IF;
    message.set_string_property('MESSAGE_ID',
                                p_message_id);
    LOOP
      EXIT WHEN idx IS NULL;
      message.set_string_property('BENTITY_' || p_entity_list(idx),
                                  p_entity_list(idx));
      idx := p_entity_list.NEXT(idx);
    END LOOP;
    message.set_boolean_property('SYNC_PUBLISHER_ENABLED',
                                 p_sync_publisher_enabled);
    message.set_text(p_xml);

    enqueue_options.visibility := dbms_aq.on_commit;

    dbms_aq.enqueue(queue_name         => SYNC_TOPIC,
                    enqueue_options    => enqueue_options,
                    message_properties => message_properties,
                    payload            => message,
                    msgid              => msgid);
  EXCEPTION
    WHEN OTHERS THEN
      /**
      * If topic has subscribers associated with it and if ALL consumers have message selectors that
      * evaluate to false, then the message is discarded (message not created/delivered by AQ engine) and
      * AQ raises the exception 'ORA-24033: no recipients for message'. Supress raising this exception
      * if the topic has subscribers associated with it. This implies that all the consumers have a filter
      * and that filter condition evaluates to false.
      */
      IF (NOT (SQLCODE = -24033 AND dbms_aqadm.queue_subscribers(SYNC_TOPIC)
          .COUNT > 0)) THEN
        RAISE;
      END IF;
  END p_publish_sync;
  --
  PROCEDURE p_enqueue_message(p_xml                    CLOB,
                              p_bulk_synchronization   BOOLEAN,
                              p_bulk_sync_code         VARCHAR2,
                              p_entity_list            string_nt,
                              p_vpd_inst_code          VARCHAR2,
                              p_sync_publisher_enabled BOOLEAN,
                              p_message_id             NUMBER) IS
  BEGIN
    IF (p_bulk_synchronization) THEN
      p_publish_bulk_sync(p_xml,
                          p_bulk_sync_code,
                          p_entity_list,
                          p_vpd_inst_code,
                          p_sync_publisher_enabled,
                          p_message_id);
    ELSE
      p_publish_sync(p_xml,
                     p_entity_list,
                     p_vpd_inst_code,
                     p_sync_publisher_enabled,
                     p_message_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END p_enqueue_message;
-- -- -- --
-- -- -- --
  PROCEDURE p_enqueue_msg_fragments(
                                    p_queue_name    IN VARCHAR2,
                                    p_msg_fragments IN g_msg_fragments,
                                    p_delivery_mode IN NUMBER := 1)
  IS PRAGMA AUTONOMOUS_TRANSACTION ;
    x_string             VARCHAR2(300);
    x_raw                RAW(2000);
    x_msg                g_msg_fragments;
    out_msg              g_msg_fragments;
    l_enqueue_options    DBMS_AQ.enqueue_options_t;
    l_message_properties DBMS_AQ.message_properties_t;
    l_message_handle     RAW(16);
  BEGIN
    out_msg := p_msg_fragments;
-- --
    IF p_delivery_mode = 0 THEN
      l_enqueue_options.delivery_mode := DBMS_AQ.BUFFERED;
      l_enqueue_options.visibility := DBMS_AQ.IMMEDIATE;
    ELSIF p_delivery_mode = 1 THEN
      l_enqueue_options.delivery_mode := DBMS_AQ.PERSISTENT;
      l_enqueue_options.visibility := DBMS_AQ.ON_COMMIT;
    ELSE
      l_enqueue_options.delivery_mode := DBMS_AQ.PERSISTENT_OR_BUFFERED;
    END IF;
-- --
    IF p_queue_name = 'BANINST1.GURJOBS_Q' THEN
      x_string := sys.anydata.accessVARCHAR2(p_msg_fragments.mf_02);
      GSPCRPT.P_APPLY(x_string,x_raw);
      x_msg := g_msg_fragments(
                     mf_misc_01 => p_msg_fragments.mf_misc_01,
                     mf_01      => p_msg_fragments.mf_01,
                     mf_02      => sys.anydata.ConvertRAW(x_raw),
                     mf_03      => p_msg_fragments.mf_03,
                     mf_04      => p_msg_fragments.mf_04,
                     mf_05      => p_msg_fragments.mf_05,
                     mf_06      => p_msg_fragments.mf_06,
                     mf_07      => p_msg_fragments.mf_07,
                     mf_08      => p_msg_fragments.mf_08,
                     mf_09      => p_msg_fragments.mf_09,
                     mf_10      => p_msg_fragments.mf_10);
      out_msg := x_msg;
    END IF;
-- --
    DBMS_AQ.ENQUEUE(
      queue_name            => p_queue_name,
      enqueue_options       => l_enqueue_options,
      message_properties    => l_message_properties,
      payload               => out_msg,
      msgid                 => l_message_handle
                   );

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -25207 THEN
        RAISE_APPLICATION_ERROR(-20001,
          G$_NLS.Get('GOKB_ADVQ_UTIL1-0000','SQL','*ERROR* enqueue disabled. START_QUEUE needed'||
            ' on Queue=')||p_queue_name||' ');
      ELSE
        RAISE_APPLICATION_ERROR(-20001,'GB_ADVQ_UTIL.P_ENQUEUE_MSG_FRAGMENTS'||
            SUBSTR(SQLERRM,1,255));
      END IF;
  END p_enqueue_msg_fragments;
-- -- -- -- --
-- -- -- -- --
  PROCEDURE p_dequeue_msg_fragments(
                                    p_queue_name    IN VARCHAR2,
                                    p_max_wait      IN NUMBER,
                                    p_msg_fragments OUT g_msg_fragments,
                                    p_remove_nodata IN VARCHAR2 DEFAULT 'N')
  IS PRAGMA AUTONOMOUS_TRANSACTION ;
    l_dequeue_options    DBMS_AQ.dequeue_options_t;
    l_message_properties DBMS_AQ.message_properties_t;
    l_message_handle     RAW(16);
    l_msg_fragments      g_msg_fragments;
  BEGIN
    l_dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
    IF p_max_wait IS NOT NULL THEN
      l_dequeue_options.wait := p_max_wait;
    END IF;
    IF p_remove_nodata = 'Y' THEN
      l_dequeue_options.dequeue_mode := dbms_aq.remove_nodata;
    END IF;
    DBMS_AQ.DEQUEUE(
      queue_name            => p_queue_name,
      dequeue_options       => l_dequeue_options,
      message_properties    => l_message_properties,
      payload               => l_msg_fragments,
      msgid                 => l_message_handle
                   );

    p_msg_fragments := l_msg_fragments;
    COMMIT;
  END p_dequeue_msg_fragments;
-- -- -- -- --
-- -- -- -- --
  PROCEDURE p_dequeue_msg_fragments_condit(
                                    p_queue_name    IN VARCHAR2,
                                    p_condit_value  IN VARCHAR2,
                                    p_max_wait      IN NUMBER,
                                    p_wait_factor   IN NUMBER,
                                    p_msg_fragments OUT g_msg_fragments)
  IS PRAGMA AUTONOMOUS_TRANSACTION ;
    l_dequeue_options    DBMS_AQ.dequeue_options_t;
    l_message_properties DBMS_AQ.message_properties_t;
    l_message_handle     RAW(16);
    l_msg_fragments      g_msg_fragments;
  BEGIN
    l_dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
    l_dequeue_options.wait := NVL(p_max_wait,15) * NVL(p_wait_factor,4);
    l_dequeue_options.deq_condition :=
          'GB_ADVQ_UTIL.F_GET_MF_MISC_01_VALUE(tab.user_data) = '||
          ''''||p_condit_value||'''';
    DBMS_AQ.DEQUEUE(
      queue_name            => p_queue_name,
      dequeue_options       => l_dequeue_options,
      message_properties    => l_message_properties,
      payload               => l_msg_fragments,
      msgid                 => l_message_handle
                   );
    p_msg_fragments := l_msg_fragments;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -25228 THEN
        RAISE_APPLICATION_ERROR(-20001,
          G$_NLS.Get('GOKB_ADVQ_UTIL1-0001','SQL','*ERROR* conditional Dequeue timeout. Queue=')
            ||p_queue_name||' '||SUBSTR(SQLERRM,1,57));
      ELSE
        RAISE_APPLICATION_ERROR(-20001,'GB_ADVQ_UTIL.P_DEQUEUE_MSG_FRAGMENTS'||
            '_CONDIT '||SUBSTR(SQLERRM,1,255));
      END IF;
  END p_dequeue_msg_fragments_condit;
-- -- -- --
-- -- -- --
  PROCEDURE P_PURGE_ENTIRE_QUEUE(p_queue_name     IN VARCHAR2,
                                 p_items_in_queue IN NUMBER)
  IS
    x_msg           g_msg_fragments;
    full_queue_name VARCHAR2(60);
    l_max_wait      NUMBER := 100;
    l_remove_nodata VARCHAR2(1) := 'Y'; -- for efficient removal of msgs
  BEGIN
    full_queue_name := 'BANINST1.'||p_queue_name;
    FOR counter IN 1 .. p_items_in_queue
    LOOP
      gb_advq_util.p_dequeue_msg_fragments(full_queue_name,
                                           l_max_wait,
                                           x_msg,
                                           l_remove_nodata);
    END LOOP;
  END P_PURGE_ENTIRE_QUEUE;
-- -- -- --
  PROCEDURE P_HANDSHAKE_MSG_FRAGMENTS_ENQ(
                            p_queue_name    IN VARCHAR2,
                            p_return_status OUT VARCHAR2,
                            p_mf_misc_01    IN VARCHAR2,
                            p_mf_01         IN SYS.ANYDATA,
                            p_mf_02         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_03         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_04         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_05         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_06         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_07         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_08         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_09         IN SYS.ANYDATA DEFAULT NULL,
                            p_mf_10         IN SYS.ANYDATA DEFAULT NULL)
  IS
    l_msg  g_msg_fragments;

  BEGIN
    l_msg := g_msg_fragments(
                   mf_misc_01 => p_mf_misc_01,
                   mf_01      => p_mf_01,
                   mf_02      => p_mf_02,
                   mf_03      => p_mf_03,
                   mf_04      => p_mf_04,
                   mf_05      => p_mf_05,
                   mf_06      => p_mf_06,
                   mf_07      => p_mf_07,
                   mf_08      => p_mf_08,
                   mf_09      => p_mf_09,
                   mf_10      => p_mf_10);
--
    gb_advq_util.p_enqueue_msg_fragments(p_queue_name,
                                         l_msg);
    p_return_status := '0';
--
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'GB_ADVQ_UTIL.P_HANDSHAKE_MSG_'||
          'FRAGMENTS_ENQ'||SUBSTR(SQLERRM,1,255));
  END P_HANDSHAKE_MSG_FRAGMENTS_ENQ;
-- -- -- --
  PROCEDURE P_HANDSHAKE_MSG_FRAGMENTS_DEQ1(
                           p_queue_name     IN VARCHAR2,
                           p_condit         IN VARCHAR2,
                           p_max_wait       IN NUMBER,
                           p_wait_factor    IN NUMBER,
                           p_return_status  OUT VARCHAR2,
                           p_response       OUT VARCHAR2)
  IS
    l_msg         g_msg_fragments;

  BEGIN
    gb_advq_util.p_dequeue_msg_fragments_condit(
                                         p_queue_name,
                                         p_condit,
                                         p_max_wait,
                                         p_wait_factor,
                                         l_msg);
    p_response := sys.anydata.accessVARCHAR2(l_msg.mf_01);
    p_return_status := '0';
--
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'GB_ADVQ_UTIL.P_HANDSHAKE_MSG_'||
          'FRAGMENTS_DEQ1'||SUBSTR(SQLERRM,1,255));
  END P_HANDSHAKE_MSG_FRAGMENTS_DEQ1;
-- -- -- --
-- -- -- --
  FUNCTION F_USE_AQ_AND_NOT_PIPES(p_code IN VARCHAR2,
                                  p_group_code IN VARCHAR2) RETURN BOOLEAN
  $IF DBMS_DB_VERSION.VERSION >= 11
  $THEN
    RESULT_CACHE RELIES_ON (GTVSDAX)
  $END
  IS
  CURSOR GTVSDAX_CUR IS
    SELECT GTVSDAX_EXTERNAL_CODE
      FROM GTVSDAX
     WHERE GTVSDAX_INTERNAL_CODE = p_code
       AND GTVSDAX_INTERNAL_CODE_GROUP = p_group_code;
  l_external_code VARCHAR2(15 CHAR);
  BEGIN
    OPEN GTVSDAX_CUR;
    FETCH GTVSDAX_CUR INTO l_external_code;
    IF GTVSDAX_CUR%NOTFOUND THEN
      CLOSE GTVSDAX_CUR;
      RETURN (FALSE);
    END IF;
    CLOSE GTVSDAX_CUR;
    IF l_external_code = 'Y' THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
  END F_USE_AQ_AND_NOT_PIPES;
-- -- -- --
  FUNCTION F_DBA_QUEUE_TABLE_EXISTS(p_queue_table IN VARCHAR2) RETURN BOOLEAN
  IS
    CURSOR q_cur IS
      SELECT 'x'
        FROM dba_queue_tables
       WHERE queue_table = upper(p_queue_table);
    q_rec q_cur%ROWTYPE;
  BEGIN
    OPEN q_cur;
    FETCH q_cur
      INTO q_rec;
    RETURN q_cur%FOUND;
  END f_dba_queue_table_exists;
-- -- -- --
  FUNCTION F_QUEUE_ENABLED_FOR_PURGE(p_queue_name IN VARCHAR2) RETURN BOOLEAN
  IS
    CURSOR q_cur IS
      SELECT substr(DEQUEUE_ENABLED,3,3)
        FROM dba_queues
       WHERE owner = 'BANINST1'
         AND name = UPPER(p_queue_name);
    l_dequeue_enabled VARCHAR2(7);
  BEGIN
    OPEN q_cur;
    FETCH q_cur INTO l_dequeue_enabled;
    IF q_cur%NOTFOUND THEN
      CLOSE q_cur;
      RETURN(FALSE);
    END IF;
    CLOSE q_cur;
    IF l_dequeue_enabled = 'YES' THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;
  END f_queue_enabled_for_purge;
-- -- -- --
  FUNCTION F_COUNT_QTABLE_ROWS(p_queue_table IN VARCHAR2,
                               p_query_str   OUT VARCHAR2) RETURN NUMBER
  IS
    QUERY_STR        VARCHAR2(1000);
    work_qtable_name VARCHAR2(60);
    COUNT_ROWS       NUMBER;
  BEGIN
    COUNT_ROWS := 0;
    work_qtable_name := substr(p_queue_table,4,length(p_queue_table));
    IF NOT F_DBA_QUEUE_TABLE_EXISTS(work_qtable_name) THEN
      COUNT_ROWS := 0;
      p_query_str := G$_NLS.Get('GOKB_ADVQ_UTIL1-0002','SQL','Queue Table Not Exists');
    ELSE
      QUERY_STR := 'SELECT COUNT(*) FROM '||p_queue_table;
      p_query_str := QUERY_STR;
      EXECUTE IMMEDIATE QUERY_STR
        INTO COUNT_ROWS;
    END IF;
    RETURN(COUNT_ROWS);
  END F_COUNT_QTABLE_ROWS;
-- -- -- --
  FUNCTION F_GET_UNIQUE_TOKEN RETURN VARCHAR2
  IS
    CURSOR X_CUR IS
      SELECT TO_CHAR(sysdate,'RRRRMMDDHH24MISS')||
             DBMS_SESSION.UNIQUE_SESSION_ID
        FROM DUAL;
    x_temp VARCHAR2(512);
  BEGIN
    OPEN X_CUR;
    FETCH X_CUR INTO x_temp;
    CLOSE X_CUR;
    RETURN (x_temp);
  END F_GET_UNIQUE_TOKEN;
-- -- -- --
-- -- -- --
END gb_advq_util;
/
