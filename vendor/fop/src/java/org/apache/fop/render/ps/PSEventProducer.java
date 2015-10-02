/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* $Id: PSEventProducer.java 1357883 2012-07-05 20:29:53Z gadams $ */

package org.apache.fop.render.ps;

import org.apache.fop.events.EventBroadcaster;
import org.apache.fop.events.EventProducer;

/**
 * Event producer interface for events generated by the PostScript renderer.
 */
public interface PSEventProducer extends EventProducer {

    /** Provider class for the event producer. */
    final class Provider {

        private Provider() {
        }

        /**
         * Returns an event producer.
         * @param broadcaster the event broadcaster to use
         * @return the event producer
         */
        public static PSEventProducer get(EventBroadcaster broadcaster) {
            return (PSEventProducer)broadcaster.getEventProducerFor(
                    PSEventProducer.class);
        }
    }

    /**
     * A PostScript dictionary could not be parsed.
     * @param source the event source
     * @param content the PostScript content
     * @param e the original exception
     * @event.severity ERROR
     */
    void postscriptDictionaryParseError(Object source, String content, Exception e);

    /**
     * PostScript Level 3 features are necessary.
     *
     * @param source the event source
     * @event.severity FATAL
     */
    void postscriptLevel3Needed(Object source);
}
