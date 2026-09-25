package com.yojnasetu.model;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "scheme_documents", schema = "yojna_setu")
public class SchemeDocument {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "scheme_id", nullable = false)
    private Scheme scheme;

    @Column(name = "document_name", nullable = false, length = 150)
    private String documentName;

    @Column(name = "is_mandatory", nullable = false)
    private boolean isMandatory = true;

    public SchemeDocument() {
    }

    public SchemeDocument(Scheme scheme, String documentName, boolean isMandatory) {
        this.scheme = scheme;
        this.documentName = documentName;
        this.isMandatory = isMandatory;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Scheme getScheme() {
        return scheme;
    }

    public void setScheme(Scheme scheme) {
        this.scheme = scheme;
    }

    public String getDocumentName() {
        return documentName;
    }

    public void setDocumentName(String documentName) {
        this.documentName = documentName;
    }

    public boolean isMandatory() {
        return isMandatory;
    }

    public void setMandatory(boolean mandatory) {
        isMandatory = mandatory;
    }
}
